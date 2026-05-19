import Foundation

private struct PersistedLogItem: Codable {
    let id: UUID
    let typeRawValue: String
    let detail: String
    let structuredData: LogStructuredData
    let note: String
    let duration: Int
    let imageFileNames: [String]
    let date: Date
}

private struct LegacyPersistedLogItem: Codable {
    let id: UUID
    let type: LogType
    let detail: String
    let note: String
    let duration: Int
    let imageDataList: [Data]
    let date: Date
}

private struct IntermediatePersistedLogItem: Codable {
    let id: UUID
    let typeRawValue: String
    let detail: String
    let note: String
    let duration: Int
    let imageFileNames: [String]
    let date: Date
}

enum ImageFileStore {
    nonisolated private static let directoryURL: URL = {
        let baseDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory())
        let directory = baseDirectory.appendingPathComponent("GlugPoopImages", isDirectory: true)
        if !FileManager.default.fileExists(atPath: directory.path) {
            try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        return directory
    }()

    nonisolated static func fileURL(for fileName: String) -> URL {
        directoryURL.appendingPathComponent(fileName)
    }

    nonisolated static func loadData(fileName: String) -> Data? {
        try? Data(contentsOf: fileURL(for: fileName))
    }

    nonisolated static func write(_ data: Data, fileName: String) throws {
        try data.write(to: fileURL(for: fileName), options: .atomic)
    }

    nonisolated static func remove(fileName: String) {
        try? FileManager.default.removeItem(at: fileURL(for: fileName))
    }
}

final class PersistenceController {
    static let shared = PersistenceController()

    private let fileURL: URL
    private let hydrationGoalKey = "glug_poop_hydration_goal_ml"
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    private init() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory())
        self.fileURL = documentsDirectory.appendingPathComponent("glug_poop_logs.json")

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    func loadLogs() throws -> [LogItem] {
        let persistedLogs = try loadPersistedItems()
        return persistedLogs.compactMap { persistedLog -> LogItem? in
            guard let type = LogType(rawValue: persistedLog.typeRawValue) else {
                return nil
            }
            return LogItem(
                id: persistedLog.id,
                type: type,
                detail: persistedLog.detail,
                structuredData: persistedLog.structuredData,
                note: persistedLog.note,
                duration: persistedLog.duration,
                imageFileNames: persistedLog.imageFileNames,
                date: persistedLog.date
            )
        }
    }

    func upsertLog(
        id: UUID,
        type: LogType,
        detail: String,
        structuredData: LogStructuredData,
        note: String,
        duration: Int,
        imageDataList: [Data],
        date: Date
    ) throws -> LogItem {
        var persistedLogs = try loadPersistedItems()
        let fileNames = try writeImages(for: id, imageDataList: imageDataList)

        let updatedItem = PersistedLogItem(
            id: id,
            typeRawValue: type.rawValue,
            detail: detail,
            structuredData: structuredData,
            note: note,
            duration: duration,
            imageFileNames: fileNames,
            date: date
        )

        if let index = persistedLogs.firstIndex(where: { $0.id == id }) {
            removeExtraImages(current: persistedLogs[index].imageFileNames, keeping: fileNames)
            persistedLogs[index] = updatedItem
        } else {
            persistedLogs.append(updatedItem)
        }

        try savePersistedItems(persistedLogs)

        return LogItem(
            id: id,
            type: type,
            detail: detail,
            structuredData: structuredData,
            note: note,
            duration: duration,
            imageFileNames: fileNames,
            date: date
        )
    }

    func deleteLog(id: UUID) throws {
        var persistedLogs = try loadPersistedItems()
        guard let index = persistedLogs.firstIndex(where: { $0.id == id }) else {
            return
        }

        let removed = persistedLogs.remove(at: index)
        removed.imageFileNames.forEach(ImageFileStore.remove(fileName:))
        try savePersistedItems(persistedLogs)
    }

    func loadHydrationGoalML(defaultValue: Int = 1500) -> Int {
        let storedValue = UserDefaults.standard.integer(forKey: hydrationGoalKey)
        return storedValue > 0 ? storedValue : defaultValue
    }

    func saveHydrationGoalML(_ value: Int) {
        UserDefaults.standard.set(value, forKey: hydrationGoalKey)
    }

    private func loadPersistedItems() throws -> [PersistedLogItem] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }
        let data = try Data(contentsOf: fileURL)
        if let items = try? decoder.decode([PersistedLogItem].self, from: data) {
            return items
        }

        if let intermediateItems = try? decoder.decode([IntermediatePersistedLogItem].self, from: data) {
            let migratedItems = intermediateItems.compactMap { item -> PersistedLogItem? in
                guard let type = LogType(rawValue: item.typeRawValue) else {
                    return nil
                }
                return PersistedLogItem(
                    id: item.id,
                    typeRawValue: item.typeRawValue,
                    detail: item.detail,
                    structuredData: LogStructuredData.from(type: type, detail: item.detail),
                    note: item.note,
                    duration: item.duration,
                    imageFileNames: item.imageFileNames,
                    date: item.date
                )
            }
            try savePersistedItems(migratedItems)
            return migratedItems
        }

        let legacyItems = try decoder.decode([LegacyPersistedLogItem].self, from: data)
        let migratedItems = try legacyItems.map { legacyItem in
            let fileNames = try writeImages(for: legacyItem.id, imageDataList: legacyItem.imageDataList)
            return PersistedLogItem(
                id: legacyItem.id,
                typeRawValue: legacyItem.type.rawValue,
                detail: legacyItem.detail,
                structuredData: LogStructuredData.from(type: legacyItem.type, detail: legacyItem.detail),
                note: legacyItem.note,
                duration: legacyItem.duration,
                imageFileNames: fileNames,
                date: legacyItem.date
            )
        }
        try savePersistedItems(migratedItems)
        return migratedItems
    }

    private func savePersistedItems(_ items: [PersistedLogItem]) throws {
        let data = try encoder.encode(items)
        try data.write(to: fileURL, options: .atomic)
    }

    private func writeImages(for id: UUID, imageDataList: [Data]) throws -> [String] {
        let fileNames = imageDataList.enumerated().map { index, _ in
            "\(id.uuidString)-\(index).jpg"
        }

        for (index, imageData) in imageDataList.enumerated() {
            try ImageFileStore.write(imageData, fileName: fileNames[index])
        }

        return fileNames
    }

    private func removeExtraImages(current: [String], keeping: [String]) {
        let retainedNames = Set(keeping)
        for fileName in current where !retainedNames.contains(fileName) {
            ImageFileStore.remove(fileName: fileName)
        }
    }
}
