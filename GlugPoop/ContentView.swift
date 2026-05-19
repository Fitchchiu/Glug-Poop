import SwiftUI
import Combine
import UIKit

private enum AppTheme {
    static let black = Color(hex: "1C1C1E")
    static let lightGray = Color(hex: "F2F2F7")
    static let water = Color(hex: "007AFF")
    static let drink = Color(hex: "AF52DE")
    static let food = Color(hex: "FF2D55")
    static let poop = Color(hex: "FFCC00")
    static let vibe1 = Color(hex: "FF2D55").opacity(0.8)
    static let vibe2 = Color(hex: "FFCC00").opacity(0.8)
    static let vibe3 = Color(hex: "AF52DE").opacity(0.6)
    static let vibe4 = Color(hex: "34C759").opacity(0.8)
    static let vibe5 = Color(hex: "007AFF").opacity(0.8)
}

private enum LayoutMetrics {
    static let homeGridColumns = Array(repeating: GridItem(.flexible(), spacing: 20), count: 2)
    static let waterGridColumns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)
    static let pairGridColumns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 2)
    static let poopGridColumns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 4)
    static let calendarColumns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 7)
}

private enum DataSets {
    static let waterOptions = [100, 300, 500, 750, 1000]
    static let drinks = [("Coffee", "☕️", "9E7B62"), ("Boba", "🧋", "D4B59D"), ("Soda", "🥤", "FF5E3A"), ("Matcha", "🍵", "8EFA48"), ("Wine", "🍷", "800020"), ("Beer", "🍺", "F28E1C")]
    static let drinkTemperatures = ["Cold", "Hot"]
    static let drinkSugarLevels = ["Sugar Free", "Low", "Medium", "High"]
    static let drinkCaffeineOptions = [
        DrinkDetailOption(id: "no", icon: "leaf.fill", title: "No Caffeine", subtitle: "Gentle", usesSystemImage: true),
        DrinkDetailOption(id: "yes", icon: "bolt.fill", title: "Caffeine", subtitle: "Boost", usesSystemImage: true),
    ]
    static let drinkTemperatureOptions = [
        DrinkDetailOption(id: "Cold", icon: "snowflake", title: "Cold", subtitle: "Chilled", usesSystemImage: true),
        DrinkDetailOption(id: "Hot", icon: "sun.max.fill", title: "Hot", subtitle: "Warm", usesSystemImage: true),
    ]
    static let drinkSugarOptions = [
        DrinkDetailOption(id: "Sugar Free", icon: "drop", title: "Sugar Free", subtitle: "Clean", usesSystemImage: true),
        DrinkDetailOption(id: "Low", icon: "drop.fill", title: "Low", subtitle: "Light", usesSystemImage: true),
        DrinkDetailOption(id: "Medium", icon: "drop.triangle", title: "Medium", subtitle: "Balanced", usesSystemImage: true),
        DrinkDetailOption(id: "High", icon: "aqi.high", title: "High", subtitle: "Sweet", usesSystemImage: true),
    ]
    static let foods = [("Burger🍔", "FFCC00"), ("Salad🥗", "007AFF"), ("Pizza🍕", "FF2D55"), ("Sushi🍣", "34C759"), ("Tacos🌮", "FFCC00"), ("Ramen🍜", "007AFF"), ("Meat🥩", "FF2D55"), ("Sweet🍩", "AF52DE")]
    static let poops = [
        PoopOption(id: "poop_1", imageName: "poop_1", legacyValues: ["💨"]),
        PoopOption(id: "poop_2", imageName: "poop_2", legacyValues: ["🤬"]),
        PoopOption(id: "poop_3", imageName: "poop_3", legacyValues: ["😖"]),
        PoopOption(id: "poop_4", imageName: "poop_4", legacyValues: ["😌"]),
        PoopOption(id: "poop_5", imageName: "poop_5", legacyValues: ["☺️"]),
        PoopOption(id: "poop_6", imageName: "poop_6", legacyValues: ["🫠", "🤢"]),
        PoopOption(id: "poop_7", imageName: "poop_7", legacyValues: ["🌋"]),
        PoopOption(id: "poop_8", imageName: "poop_8", legacyValues: []),
    ]
    static let poopColors = [
        PoopColorOption(id: "light_gray", color: Color(hex: "E4D7B4"), label: "Light Tan"),
        PoopColorOption(id: "yellow", color: Color(hex: "FFCC33"), label: "Yellow"),
        PoopColorOption(id: "tan", color: Color(hex: "CFA766"), label: "Tan"),
        PoopColorOption(id: "coffee", color: Color(hex: "7B4308"), label: "Coffee"),
        PoopColorOption(id: "dark_brown", color: Color(hex: "5A3217"), label: "Dark Brown"),
        PoopColorOption(id: "green", color: Color(hex: "005A21"), label: "Green"),
        PoopColorOption(id: "black", color: Color(hex: "000000"), label: "Black"),
        PoopColorOption(id: "red", color: Color(hex: "C70000"), label: "Red"),
    ]
    static let poopSymptoms = [
        PoopSymptomOption(id: "comfortable", emoji: "😆", label: "舒畅"),
        PoopSymptomOption(id: "constipation", emoji: "🤯", label: "便秘"),
        PoopSymptomOption(id: "pain", emoji: "💥", label: "腹痛"),
        PoopSymptomOption(id: "urgent", emoji: "😩", label: "紧急"),
    ]
}

private struct PoopOption: Hashable {
    let id: String
    let imageName: String
    let legacyValues: [String]
}

private struct PoopColorOption: Hashable {
    let id: String
    let color: Color
    let label: String
}

private struct PoopSymptomOption: Hashable {
    let id: String
    let emoji: String
    let label: String
}

private struct DrinkDetailOption: Hashable {
    let id: String
    let icon: String
    let title: String
    let subtitle: String
    let usesSystemImage: Bool
}

private enum Formatters {
    static let wholeNumber: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    static let logTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    static let monthYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter
    }()

    static let fullDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }()
}

private enum ImageDecoder {
    nonisolated(unsafe) static let cache = NSCache<NSData, UIImage>()

    nonisolated static func image(from data: Data) -> UIImage? {
        let key = data as NSData
        if let cached = cache.object(forKey: key) {
            return cached
        }
        guard let image = UIImage(data: data) else {
            return nil
        }
        cache.setObject(image, forKey: key)
        return image
    }
}

private enum PoopAssetLoader {
    nonisolated static func image(named name: String) -> UIImage? {
        if let image = UIImage(named: name) {
            return image
        }
        guard let path = Bundle.main.path(forResource: name, ofType: "png", inDirectory: "BristolStoolScale") else {
            return nil
        }
        return UIImage(contentsOfFile: path)
    }
}

private enum PoopOptionResolver {
    static let defaultColorID = "coffee"

    static func normalizedID(for value: String) -> String {
        if DataSets.poops.contains(where: { $0.id == value }) {
            return value
        }
        return DataSets.poops.first(where: { $0.legacyValues.contains(value) })?.id ?? "poop_4"
    }

    static func option(for value: String) -> PoopOption? {
        let normalizedID = normalizedID(for: value)
        return DataSets.poops.first(where: { $0.id == normalizedID })
    }
}

private struct PoopRecordValue {
    let shapeID: String
    let colorID: String

    init(shapeID: String, colorID: String) {
        self.shapeID = PoopOptionResolver.normalizedID(for: shapeID)
        if DataSets.poopColors.contains(where: { $0.id == colorID }) {
            self.colorID = colorID
        } else {
            self.colorID = PoopOptionResolver.defaultColorID
        }
    }

    init(detail: String) {
        let parts = detail.split(separator: "|", maxSplits: 1).map(String.init)
        self.shapeID = PoopOptionResolver.normalizedID(for: parts.first ?? detail)
        if let rawColorID = parts.dropFirst().first,
           DataSets.poopColors.contains(where: { $0.id == rawColorID }) {
            self.colorID = rawColorID
        } else {
            self.colorID = PoopOptionResolver.defaultColorID
        }
    }

    var detailValue: String {
        "\(shapeID)|\(colorID)"
    }

    var colorOption: PoopColorOption? {
        DataSets.poopColors.first(where: { $0.id == colorID })
    }
}

struct LogStructuredData: Hashable, Codable {
    var waterML: Int?
    var drinkType: String?
    var drinkHasCaffeine: Bool?
    var drinkTemperature: String?
    var drinkSugarLevel: String?
    var foodType: String?
    var poopShapeID: String?
    var poopColorID: String?
    var poopSymptomID: String?
    var poopHasEffort: Bool?
    var poopHasPain: Bool?
    var poopHasIncompleteFeeling: Bool?
    var poopIsUrgent: Bool?

    static func from(type: LogType, detail: String) -> LogStructuredData {
        switch type {
        case .water:
            let waterML = Int(detail.replacingOccurrences(of: "ml", with: "")) ?? 0
            return LogStructuredData(waterML: waterML)
        case .drink:
            return LogStructuredData(drinkType: detail)
        case .food:
            return LogStructuredData(foodType: detail)
        case .poop:
            let poopRecord = PoopRecordValue(detail: detail)
            return LogStructuredData(
                poopShapeID: poopRecord.shapeID,
                poopColorID: poopRecord.colorID
            )
        }
    }

    var displayDetail: String {
        if let waterML {
            return "\(waterML)ml"
        }
        if let drinkType {
            return drinkType
        }
        if let foodType {
            return foodType
        }
        if let poopShapeID {
            let colorID = poopColorID ?? PoopOptionResolver.defaultColorID
            return PoopRecordValue(shapeID: poopShapeID, colorID: colorID).detailValue
        }
        return ""
    }

    init(
        waterML: Int? = nil,
        drinkType: String? = nil,
        drinkHasCaffeine: Bool? = nil,
        drinkTemperature: String? = nil,
        drinkSugarLevel: String? = nil,
        foodType: String? = nil,
        poopShapeID: String? = nil,
        poopColorID: String? = nil
        ,
        poopSymptomID: String? = nil,
        poopHasEffort: Bool? = nil,
        poopHasPain: Bool? = nil,
        poopHasIncompleteFeeling: Bool? = nil,
        poopIsUrgent: Bool? = nil
    ) {
        self.waterML = waterML
        self.drinkType = drinkType
        self.drinkHasCaffeine = drinkHasCaffeine
        self.drinkTemperature = drinkTemperature
        self.drinkSugarLevel = drinkSugarLevel
        self.foodType = foodType
        self.poopShapeID = poopShapeID
        self.poopColorID = poopColorID
        self.poopSymptomID = poopSymptomID
        self.poopHasEffort = poopHasEffort
        self.poopHasPain = poopHasPain
        self.poopHasIncompleteFeeling = poopHasIncompleteFeeling
        self.poopIsUrgent = poopIsUrgent
    }

    var resolvedPoopSymptomID: String? {
        if let poopSymptomID {
            return poopSymptomID
        }
        if poopIsUrgent == true { return "urgent" }
        if poopHasPain == true { return "pain" }
        if poopHasEffort == true || poopHasIncompleteFeeling == true { return "constipation" }
        return nil
    }
}

// MARK: - 1. 数据模型与状态管理
struct LogItem: Identifiable, Hashable {
    let id: UUID
    let type: LogType
    let detail: String
    let structuredData: LogStructuredData
    let note: String
    let duration: Int
    let imageFileNames: [String]
    let date: Date
    var imageDataList: [Data] { imageFileNames.compactMap(ImageFileStore.loadData(fileName:)) }
    var imageData: Data? { imageFileNames.first.flatMap(ImageFileStore.loadData(fileName:)) }
    var primaryDisplayText: String {
        if !detail.isEmpty { return detail }
        return structuredData.displayDetail
    }
    var primaryValueStyle: CardPrimaryValue.Style {
        switch type {
        case .water:
            return .numeric
        case .drink, .food:
            return .label
        case .poop:
            return .label
        }
    }
    var drinkSummaryTags: [String] {
        guard type == .drink else { return [] }
        var tags: [String] = []
        if structuredData.drinkHasCaffeine == true { tags.append("Caffeine") }
        if let drinkTemperature = structuredData.drinkTemperature { tags.append(drinkTemperature) }
        if let drinkSugarLevel = structuredData.drinkSugarLevel { tags.append(drinkSugarLevel) }
        return tags
    }
    var poopSymptomTags: [String] {
        guard type == .poop else { return [] }
        guard let symptomID = structuredData.resolvedPoopSymptomID,
              let option = DataSets.poopSymptoms.first(where: { $0.id == symptomID }) else {
            return []
        }
        return ["\(option.emoji) \(option.label)"]
    }
    
    init(
        id: UUID = UUID(),
        type: LogType,
        detail: String,
        structuredData: LogStructuredData? = nil,
        note: String,
        duration: Int,
        imageFileNames: [String],
        date: Date
    ) {
        self.id = id
        self.type = type
        self.structuredData = structuredData ?? LogStructuredData.from(type: type, detail: detail)
        self.detail = detail.isEmpty ? self.structuredData.displayDetail : detail
        self.note = note
        self.duration = duration
        self.imageFileNames = imageFileNames
        self.date = date
    }
}

enum LogType: String, CaseIterable, Codable {
    case water, drink, food, poop
    var color: Color {
        switch self {
        case .water: return AppTheme.water
        case .drink: return AppTheme.drink
        case .food: return AppTheme.food
        case .poop: return AppTheme.poop
        }
    }
    var title: String {
        switch self {
        case .water: return "WATER"
        case .drink: return "DRINKS"
        case .food: return "FOOD"
        case .poop: return "POOP"
        }
    }
    var icon: String {
        switch self {
        case .water: return "💧"
        case .drink: return "🧋"
        case .food: return "🍔"
        case .poop: return "💩"
        }
    }
}

enum VibeLevel: Int {
    case level1 = 1, level2, level3, level4, level5
    var color: Color {
        switch self {
        case .level1: return AppTheme.vibe1
        case .level2: return AppTheme.vibe2
        case .level3: return AppTheme.vibe3
        case .level4: return AppTheme.vibe4
        case .level5: return AppTheme.vibe5
        }
    }
}

@MainActor
final class AppViewModel: ObservableObject {
    @Published var logs: [LogItem] = []
    @Published var vibeScore: Int = 70
    @Published var aiJudgeText: String = "\"今天表现平平，像个没有感情的产屎机器。🙄\""
    @Published var hydrationGoalML: Int
    private let calendar = Calendar.current
    private let persistenceController: PersistenceController
    private var logsByDay: [Date: [LogItem]] = [:]
    private var calendarGridCache: [MonthCacheKey: [Date?]] = [:]

    init(persistenceController: PersistenceController) {
        self.persistenceController = persistenceController
        self.hydrationGoalML = persistenceController.loadHydrationGoalML()
        loadPersistedLogs()
    }
    
    func addLog(type: LogType, detail: String, structuredData: LogStructuredData? = nil, note: String, duration: Int, imageDataList: [Data], date: Date) {
        let resolvedStructuredData = structuredData ?? LogStructuredData.from(type: type, detail: detail)
        do {
            let persistedLog = try persistenceController.upsertLog(
                id: UUID(),
                type: type,
                detail: detail,
                structuredData: resolvedStructuredData,
                note: note,
                duration: duration,
                imageDataList: imageDataList,
                date: date
            )
            let insertIndex = logs.insertionIndex(of: persistedLog) { $0.date > $1.date }
            logs.insert(persistedLog, at: insertIndex)
            insertIntoDayIndex(persistedLog)
        } catch {
            print("Failed to add log: \(error)")
        }
        generateAIToast(for: type, detail: detail)
    }
    
    func updateLog(id: UUID, detail: String, structuredData: LogStructuredData? = nil, note: String, duration: Int, imageDataList: [Data], date: Date) {
        if let index = logs.firstIndex(where: { $0.id == id }) {
            let oldLog = logs[index]
            let resolvedStructuredData = structuredData ?? LogStructuredData.from(type: oldLog.type, detail: detail)
            do {
                let updatedLog = try persistenceController.upsertLog(
                    id: id,
                    type: oldLog.type,
                    detail: detail,
                    structuredData: resolvedStructuredData,
                    note: note,
                    duration: duration,
                    imageDataList: imageDataList,
                    date: date
                )
                logs.remove(at: index)
                removeFromDayIndex(oldLog)
                let insertIndex = logs.insertionIndex(of: updatedLog) { $0.date > $1.date }
                logs.insert(updatedLog, at: insertIndex)
                insertIntoDayIndex(updatedLog)
            } catch {
                print("Failed to update log: \(error)")
            }
        }
    }

    func deleteLog(id: UUID) {
        guard let index = logs.firstIndex(where: { $0.id == id }) else {
            return
        }
        do {
            try persistenceController.deleteLog(id: id)
            let removedLog = logs.remove(at: index)
            removeFromDayIndex(removedLog)
        } catch {
            print("Failed to delete log: \(error)")
        }
    }
    
    private func generateAIToast(for type: LogType, detail: String) {
        switch type {
        case .water: aiJudgeText = "\"居然只有这点水？你是打算直接把自己做成木乃伊吗？🐱\""
        case .drink: aiJudgeText = "\"又喝糖水？你的胰岛素正在向你竖中指。🖕\""; vibeScore -= 2
        case .food: aiJudgeText = "\"这顿大餐下去，你的肠道已经在写遗嘱了。🍔\""; vibeScore += 1
        case .poop: aiJudgeText = "\"罕见的完美排泄。别骄傲，这大概是你今天唯一的成就。🚽\""; vibeScore += 3
        }
    }
    
    func logs(for date: Date) -> [LogItem] {
        logsByDay[calendar.startOfDay(for: date)] ?? []
    }
    
    func mockAIVibe(for date: Date) -> VibeLevel? {
        let count = logCount(for: date)
        if count == 0 { return nil }
        if count >= 6 { return .level5 }
        if count >= 4 { return .level4 }
        if count >= 3 { return .level3 }
        if count >= 2 { return .level2 }
        return .level1
    }
    
    func generateCalendarGrid(for date: Date) -> [Date?] {
        let key = MonthCacheKey(date: date, calendar: calendar)
        if let cached = calendarGridCache[key] {
            return cached
        }

        var days: [Date?] = []
        let components = calendar.dateComponents([.year, .month], from: date)
        guard let firstDay = calendar.date(from: components) else { return [] }
        let firstWeekday = calendar.component(.weekday, from: firstDay) - 1
        for _ in 0..<firstWeekday { days.append(nil) }
        let daysInMonth = calendar.range(of: .day, in: .month, for: date)!.count
        for day in 1...daysInMonth { var dayComp = components; dayComp.day = day; days.append(calendar.date(from: dayComp)) }
        calendarGridCache[key] = days
        return days
    }

    func logCount(for date: Date) -> Int {
        logsByDay[calendar.startOfDay(for: date)]?.count ?? 0
    }

    func totalWater(on date: Date) -> Int {
        logs(for: date)
            .filter { $0.type == .water }
            .reduce(0) { $0 + ($1.structuredData.waterML ?? 0) }
    }

    func logsCount(from startDate: Date, to endDate: Date) -> Int {
        logs.filter { $0.date >= startDate && $0.date <= endDate }.count
    }

    func logsGroupedByType(from startDate: Date, to endDate: Date) -> [LogType: Int] {
        logs.reduce(into: [LogType: Int]()) { partialResult, log in
            guard log.date >= startDate && log.date <= endDate else {
                return
            }
            partialResult[log.type, default: 0] += 1
        }
    }

    func poopLogs(from startDate: Date, to endDate: Date) -> [LogItem] {
        logs.filter { $0.type == .poop && $0.date >= startDate && $0.date <= endDate }
    }

    func poopLogs(shapeID: String? = nil, colorID: String? = nil, from startDate: Date, to endDate: Date) -> [LogItem] {
        poopLogs(from: startDate, to: endDate).filter { log in
            let matchesShape = shapeID == nil || log.structuredData.poopShapeID == shapeID
            let matchesColor = colorID == nil || log.structuredData.poopColorID == colorID
            return matchesShape && matchesColor
        }
    }

    func logs(of type: LogType, from startDate: Date, to endDate: Date) -> [LogItem] {
        logs.filter { $0.type == type && $0.date >= startDate && $0.date <= endDate }
    }

    func waterSeries(from startDate: Date, to endDate: Date) -> [(date: Date, totalML: Int)] {
        let days = dateSeries(from: startDate, to: endDate)
        return days.map { day in
            (date: day, totalML: totalWater(on: day))
        }
    }

    func averageDailyWater(from startDate: Date, to endDate: Date) -> Int {
        let series = waterSeries(from: startDate, to: endDate)
        guard !series.isEmpty else { return 0 }
        let total = series.reduce(0) { $0 + $1.totalML }
        return Int((Double(total) / Double(series.count)).rounded())
    }

    func bestWaterDay(from startDate: Date, to endDate: Date) -> (date: Date, totalML: Int)? {
        waterSeries(from: startDate, to: endDate).max { lhs, rhs in
            lhs.totalML < rhs.totalML
        }
    }

    func lowestWaterDay(from startDate: Date, to endDate: Date) -> (date: Date, totalML: Int)? {
        waterSeries(from: startDate, to: endDate).min { lhs, rhs in
            lhs.totalML < rhs.totalML
        }
    }

    func poopShapeCounts(from startDate: Date, to endDate: Date) -> [String: Int] {
        poopLogs(from: startDate, to: endDate).reduce(into: [String: Int]()) { partialResult, log in
            let shapeID = log.structuredData.poopShapeID ?? "poop_4"
            partialResult[shapeID, default: 0] += 1
        }
    }

    func poopColorCounts(from startDate: Date, to endDate: Date) -> [String: Int] {
        poopLogs(from: startDate, to: endDate).reduce(into: [String: Int]()) { partialResult, log in
            let colorID = log.structuredData.poopColorID ?? PoopOptionResolver.defaultColorID
            partialResult[colorID, default: 0] += 1
        }
    }

    func consecutiveLoggingDays(through endDate: Date = Date()) -> Int {
        var streak = 0
        var currentDay = calendar.startOfDay(for: endDate)

        while logCount(for: currentDay) > 0 {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDay) else {
                break
            }
            currentDay = previousDay
        }

        return streak
    }

    func hydrationGoalHitRate(from startDate: Date, to endDate: Date, goalML: Int) -> Double {
        let days = dateSeries(from: startDate, to: endDate)
        guard !days.isEmpty else { return 0 }
        let hitDays = days.filter { totalWater(on: $0) >= goalML }.count
        return Double(hitDays) / Double(days.count)
    }

    func updateHydrationGoalML(_ value: Int) {
        hydrationGoalML = value
        persistenceController.saveHydrationGoalML(value)
    }

    private func dateSeries(from startDate: Date, to endDate: Date) -> [Date] {
        var result: [Date] = []
        var current = calendar.startOfDay(for: startDate)
        let end = calendar.startOfDay(for: endDate)

        while current <= end {
            result.append(current)
            guard let next = calendar.date(byAdding: .day, value: 1, to: current) else {
                break
            }
            current = next
        }

        return result
    }

    private func insertIntoDayIndex(_ log: LogItem) {
        let day = calendar.startOfDay(for: log.date)
        var dayLogs = logsByDay[day] ?? []
        let insertIndex = dayLogs.insertionIndex(of: log) { $0.date > $1.date }
        dayLogs.insert(log, at: insertIndex)
        logsByDay[day] = dayLogs
    }

    private func removeFromDayIndex(_ log: LogItem) {
        let day = calendar.startOfDay(for: log.date)
        guard var dayLogs = logsByDay[day] else {
            return
        }
        dayLogs.removeAll { $0.id == log.id }
        logsByDay[day] = dayLogs.isEmpty ? nil : dayLogs
    }
    
    private func loadPersistedLogs() {
        do {
            let persistedLogs = try persistenceController.loadLogs()
            if persistedLogs.isEmpty {
                prefillDummyData()
                return
            }
            logs = persistedLogs.sorted { $0.date > $1.date }
            rebuildDayIndex()
        } catch {
            print("Failed to fetch persisted logs: \(error)")
            logs = []
            logsByDay = [:]
        }
    }

    private func rebuildDayIndex() {
        logsByDay = [:]
        for log in logs {
            insertIntoDayIndex(log)
        }
    }

    private func prefillDummyData() {
        let past = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        addLog(type: .water, detail: "500ml", note: "起床第一杯", duration: 0, imageDataList: [], date: past)
    }
}

private enum RootTab: Hashable {
    case records
    case dashboard
    case calendar
    case stats
}

private enum StatsRange: String, CaseIterable, Hashable {
    case week = "近7天"
    case twoWeeks = "近14天"
    case month = "近30天"

    var days: Int {
        switch self {
        case .week: return 7
        case .twoWeeks: return 14
        case .month: return 30
        }
    }
}

enum StatsDetailContext: Identifiable, Hashable {
    case day(Date)
    case type(LogType, Date, Date)
    case poopShape(String, Date, Date)
    case poopColor(String, Date, Date)

    var id: String {
        switch self {
        case .day(let date):
            return "day-\(date.timeIntervalSince1970)"
        case .type(let type, let startDate, let endDate):
            return "type-\(type.rawValue)-\(startDate.timeIntervalSince1970)-\(endDate.timeIntervalSince1970)"
        case .poopShape(let shapeID, let startDate, let endDate):
            return "shape-\(shapeID)-\(startDate.timeIntervalSince1970)-\(endDate.timeIntervalSince1970)"
        case .poopColor(let colorID, let startDate, let endDate):
            return "color-\(colorID)-\(startDate.timeIntervalSince1970)-\(endDate.timeIntervalSince1970)"
        }
    }
}

// MARK: - 2. 核心组件系统
struct ModernCardStyle: ViewModifier {
    var bgColor: Color; var cornerRadius: CGFloat = 32
    func body(content: Content) -> some View {
        content
            .background(bgColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 10)
    }
}
extension View { func modernStyle(color: Color, radius: CGFloat = 32) -> some View { self.modifier(ModernCardStyle(bgColor: color, cornerRadius: radius)) } }

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View { configuration.label.scaleEffect(configuration.isPressed ? 0.95 : 1).animation(.spring(response: 0.4, dampingFraction: 0.6), value: configuration.isPressed) }
}

struct TogglePillRow<Value: Hashable>: View {
    let title: String
    let options: [(String, Value)]
    @Binding var selection: Value
    let themeColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.gray)
            HStack(spacing: 10) {
                ForEach(options, id: \.0) { option in
                    Button(action: { selection = option.1 }) {
                        Text(option.0)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(selection == option.1 ? .white : .black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .modernStyle(color: selection == option.1 ? themeColor : AppTheme.lightGray, radius: 100)
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
        }
    }
}

struct FormSectionCard<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.gray)
                .textCase(.uppercase)
            content
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(AppTheme.lightGray.opacity(0.9))
        )
    }
}

struct SymptomToggleButton: View {
    let title: String
    @Binding var isOn: Bool
    let themeColor: Color

    var body: some View {
        Button(action: { isOn.toggle() }) {
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(isOn ? .white : .black)
                .frame(maxWidth: .infinity)
                .frame(height: 42)
                .modernStyle(color: isOn ? themeColor : AppTheme.lightGray, radius: 16)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct TagFlowLayout: Layout {
    var horizontalSpacing: CGFloat = 6
    var verticalSpacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .greatestFiniteMagnitude
        var currentRowWidth: CGFloat = 0
        var currentRowHeight: CGFloat = 0
        var totalWidth: CGFloat = 0
        var totalHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            let nextWidth = currentRowWidth == 0 ? size.width : currentRowWidth + horizontalSpacing + size.width

            if nextWidth > maxWidth, currentRowWidth > 0 {
                totalWidth = max(totalWidth, currentRowWidth)
                totalHeight += currentRowHeight + verticalSpacing
                currentRowWidth = size.width
                currentRowHeight = size.height
            } else {
                currentRowWidth = nextWidth
                currentRowHeight = max(currentRowHeight, size.height)
            }
        }

        totalWidth = max(totalWidth, currentRowWidth)
        totalHeight += currentRowHeight
        return CGSize(width: min(totalWidth, maxWidth), height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var origin = CGPoint(x: bounds.minX, y: bounds.minY)
        var currentRowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            let nextX = origin.x + size.width

            if nextX > bounds.maxX, origin.x > bounds.minX {
                origin.x = bounds.minX
                origin.y += currentRowHeight + verticalSpacing
                currentRowHeight = 0
            }

            subview.place(
                at: CGPoint(x: origin.x, y: origin.y),
                anchor: .topLeading,
                proposal: ProposedViewSize(width: size.width, height: size.height)
            )

            origin.x += size.width + horizontalSpacing
            currentRowHeight = max(currentRowHeight, size.height)
        }
    }
}

struct SelectionDetailButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let isSelected: Bool
    let themeColor: Color
    var usesSystemImage: Bool = false

    var body: some View {
        VStack(spacing: 4) {
            Group {
                if usesSystemImage {
                    Image(systemName: icon)
                } else {
                    Text(icon)
                }
            }
            .font(.system(size: 16, weight: .bold))

            Text(title)
                .font(.system(size: 13, weight: .bold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text(subtitle)
                .font(.system(size: 10, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.85)
                .opacity(0.72)
        }
        .foregroundColor(isSelected ? .white : AppTheme.black)
        .frame(maxWidth: .infinity)
        .frame(height: 68)
        .modernStyle(color: isSelected ? themeColor : .white, radius: 16)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(isSelected ? themeColor.opacity(0.18) : Color.clear, lineWidth: 1)
        )
    }
}

struct CardMetaPill: View {
    let text: String
    let foregroundColor: Color
    let backgroundColor: Color

    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(foregroundColor)
            .lineLimit(1)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(backgroundColor)
            .clipShape(Capsule())
    }
}

struct CardPrimaryValue: View {
    enum Style {
        case numeric
        case label
    }

    let text: String
    let foregroundColor: Color
    let backgroundColor: Color
    var style: Style = .label

    var body: some View {
        Text(text)
            .font(font)
            .foregroundColor(foregroundColor)
            .lineLimit(style == .numeric ? 1 : 2)
            .minimumScaleFactor(0.76)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, style == .numeric ? 14 : 12)
            .padding(.vertical, style == .numeric ? 12 : 10)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var font: Font {
        switch style {
        case .numeric:
            return .system(size: 22, weight: .black, design: .rounded)
        case .label:
            return .system(size: 19, weight: .black, design: .rounded)
        }
    }
}

struct InfoTagWrap: View {
    let tags: [String]
    let foregroundColor: Color
    let backgroundColor: Color

    var body: some View {
        if !tags.isEmpty {
            TagFlowLayout(horizontalSpacing: 6, verticalSpacing: 6) {
                ForEach(tags, id: \.self) { tag in
                    Text(tag)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(foregroundColor)
                        .lineLimit(1)
                        .fixedSize()
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(backgroundColor)
                        .clipShape(Capsule())
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct GridBackground: View {
    var body: some View {
        ZStack {
            Color.white
            Canvas { context, size in
                var path = Path()
                let step: CGFloat = 30
                for x in stride(from: 0, through: size.width, by: step) {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: size.height))
                }
                for y in stride(from: 0, through: size.height, by: step) {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                }
                context.stroke(path, with: .color(.gray.opacity(0.05)), lineWidth: 1)
            }
        }
        .ignoresSafeArea()
    }
}

struct ImagePickerView: UIViewControllerRepresentable {
    @Binding var selectedImages: [Data]; @Environment(\.presentationMode) private var presentationMode
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    func makeUIViewController(context: Context) -> UIImagePickerController { let picker = UIImagePickerController(); picker.delegate = context.coordinator; picker.sourceType = sourceType; picker.allowsEditing = true; return picker }
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePickerView; init(_ parent: ImagePickerView) { self.parent = parent }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage, let data = image.jpegData(compressionQuality: 0.6) {
                parent.selectedImages.append(data)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

enum SheetContext: Identifiable {
    case new(LogType, Date); case edit(LogItem)
    var id: String {
        switch self {
        case .new(let type, let date): return "new_\(type)_\(date.timeIntervalSince1970)"
        case .edit(let log): return "edit_\(log.id)"
        }
    }
}

// MARK: - 3. 主视图导航
struct ContentView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var selectedTab: RootTab = .records
    
    var body: some View {
        TabView(selection: $selectedTab) {
            RecordsHomeView()
                .tabItem {
                    Label("记录", systemImage: "square.grid.2x2.fill")
                }
                .tag(RootTab.records)

            DashboardView(showBackButton: false)
                .tabItem {
                    Label("Dashboard", systemImage: "rectangle.3.group.bubble.left.fill")
                }
                .tag(RootTab.dashboard)

            VibeCalendarView(showBackButton: false)
                .tabItem {
                    Label("日历", systemImage: "calendar")
                }
                .tag(RootTab.calendar)

            StatsView()
                .tabItem {
                    Label("统计", systemImage: "chart.bar.fill")
                }
                .tag(RootTab.stats)
        }
    }
}

struct RecordsHomeView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var activeSheet: SheetContext? = nil

    var body: some View {
        ZStack {
            GridBackground()
            VStack(spacing: 30) {
                VStack(spacing: 5) {
                    Text("VIBE CHECK").font(.system(size: 34, weight: .black, design: .rounded))
                    Text("Log your daily inputs & outputs.").font(.system(size: 17, weight: .semibold)).foregroundColor(AppTheme.black.opacity(0.6))
                }
                .padding(.top, 50)

                Spacer()

                LazyVGrid(columns: LayoutMetrics.homeGridColumns, spacing: 20) {
                    ForEach(LogType.allCases, id: \.self) { type in
                        Button(action: { activeSheet = .new(type, Date()) }) {
                            VStack(alignment: .leading) {
                                HStack { Spacer(); Text(type.icon).font(.system(size: 40)) }
                                Spacer()
                                Text(type.title).font(.system(size: 20, weight: .bold, design: .rounded)).foregroundColor(type == .poop ? .black : .white)
                            }
                            .padding(20)
                            .aspectRatio(1, contentMode: .fill)
                            .modernStyle(color: type.color, radius: 32)
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                }
                .padding(.horizontal, 24)

                Spacer()
            }
        }
        .sheet(item: $activeSheet) { context in
            InputSheetRouter(context: context)
                .presentationDetents([.height(context.sheetHeight)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
                .presentationBackground(.white)
        }
    }
}

struct InputSheetRouter: View {
    let context: SheetContext
    var body: some View {
        switch context {
        case .new(let type, let date):
            switch type {
            case .water: WaterInputSheet(editLog: nil, initialDate: date)
            case .drink: DrinkInputSheet(editLog: nil, initialDate: date)
            case .food: FoodInputSheet(editLog: nil, initialDate: date)
            case .poop: PoopInputSheet(editLog: nil, initialDate: date)
            }
        case .edit(let log):
            switch log.type {
            case .water: WaterInputSheet(editLog: log, initialDate: log.date)
            case .drink: DrinkInputSheet(editLog: log, initialDate: log.date)
            case .food: FoodInputSheet(editLog: log, initialDate: log.date)
            case .poop: PoopInputSheet(editLog: log, initialDate: log.date)
            }
        }
    }
}

private extension SheetContext {
    var sheetHeight: CGFloat {
        switch self {
        case .new(let type, _):
            return type.sheetHeight
        case .edit(let log):
            return log.type.sheetHeight
        }
    }
}

private extension LogType {
    var sheetHeight: CGFloat {
        switch self {
        case .water:
            return 600
        case .drink:
            return 760
        case .food:
            return 720
        case .poop:
            return 900
        }
    }
}

// MARK: - 4. 超紧凑输入面板集合
struct BaseInputSheet<Content: View>: View {
    var title: String; var isEditMode: Bool; var btnColor: Color
    @Binding var note: String; @Binding var logTime: Date; @Binding var duration: Int; @Binding var imageDataList: [Data]
    var showDuration: Bool = false; var showPhotoPicker: Bool = true; var action: () -> Void; var deleteAction: (() -> Void)? = nil; var content: Content
    @Environment(\.dismiss) var dismiss
    
    @State private var showActionSheet = false; @State private var showImagePicker = false; @State private var imageSourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var showDeleteConfirm = false
    private let previewSize: CGFloat = 50
    
    init(title: String, isEditMode: Bool, btnColor: Color, note: Binding<String>, logTime: Binding<Date>, duration: Binding<Int>, imageDataList: Binding<[Data]>, showDuration: Bool = false, showPhotoPicker: Bool = true, action: @escaping () -> Void, deleteAction: (() -> Void)? = nil, @ViewBuilder content: () -> Content) {
        self.title = title; self.isEditMode = isEditMode; self.btnColor = btnColor; self._note = note; self._logTime = logTime; self._duration = duration; self._imageDataList = imageDataList; self.showDuration = showDuration; self.showPhotoPicker = showPhotoPicker; self.action = action; self.deleteAction = deleteAction; self.content = content()
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                Text(title)
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .padding(.top, 24)

                content

                metadataPanel

                HStack(spacing: 12) {
                    if showPhotoPicker {
                        Button(action: { showActionSheet = true }) {
                            Image(systemName: "camera.fill")
                                .font(.title2)
                                .foregroundColor(.gray)
                                .frame(width: previewSize, height: previewSize)
                                .background(AppTheme.lightGray)
                                .cornerRadius(12)
                        }
                    }

                    TextField("Note (Optional)", text: $note)
                        .padding(.horizontal, 15)
                        .frame(height: previewSize)
                        .background(AppTheme.lightGray)
                        .cornerRadius(12)
                }

                if showPhotoPicker && !imageDataList.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(imageDataList.indices, id: \.self) { index in
                                if let uiImage = ImageDecoder.image(from: imageDataList[index]) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 54, height: 54)
                                        .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
                                        .overlay(Button(action: { imageDataList.remove(at: index) }) { Image(systemName: "xmark.circle.fill").foregroundColor(.white).background(Color.black.clipShape(Circle())) }.offset(x: 5, y: -5), alignment: .topTrailing)
                                }
                            }
                        }
                        .padding(.horizontal, 2)
                    }
                    .frame(height: 58)
                }

                Button(action: {
                    action()
                    dismiss()
                }) {
                    Text(isEditMode ? "UPDATE IT" : "LOG IT")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .modernStyle(color: btnColor, radius: 100)
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.bottom, 6)

                if isEditMode, deleteAction != nil {
                    Button(action: { showDeleteConfirm = true }) {
                        Text("DELETE RECORD")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .overlay(
                                RoundedRectangle(cornerRadius: 100, style: .continuous)
                                    .stroke(Color.red.opacity(0.24), lineWidth: 1.5)
                            )
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 18)
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .background(Color.white)
        .confirmationDialog("Photo Source", isPresented: $showActionSheet, titleVisibility: .hidden) { Button("Take Photo") { imageSourceType = .camera; showImagePicker = true }; Button("Photo Library") { imageSourceType = .photoLibrary; showImagePicker = true }; Button("Cancel", role: .cancel) {} }
        .confirmationDialog("Delete this record?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                deleteAction?()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
        .sheet(isPresented: $showImagePicker) { ImagePickerView(selectedImages: $imageDataList, sourceType: imageSourceType).ignoresSafeArea() }
    }

    private var metadataPanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(showDuration ? "Time & Duration" : "Time")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.gray)
                .textCase(.uppercase)

            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    compactDatePicker(.date, title: "Date")
                    compactDatePicker(.hourAndMinute, title: "Time")
                }

                if showDuration {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Duration")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.gray)
                                .textCase(.uppercase)
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text("\(duration)")
                                    .font(.system(size: 24, weight: .black, design: .rounded))
                                    .contentTransition(.numericText())
                                Text("min")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.gray)
                            }
                        }

                        Spacer(minLength: 0)

                        Stepper("", value: $duration, in: 0...120)
                            .labelsHidden()
                            .frame(width: 94)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(AppTheme.lightGray)
            )
        }
    }

    @ViewBuilder
    private func compactDatePicker(_ components: DatePickerComponents, title: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.gray)
                .textCase(.uppercase)
            DatePicker("", selection: $logTime, displayedComponents: components)
                .labelsHidden()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// 4.1 喝水 (横向紧凑版)
struct WaterInputSheet: View {
    @EnvironmentObject var viewModel: AppViewModel; var editLog: LogItem?; var initialDate: Date
    @State private var ml: Int = 300; @State private var note: String = ""; @State private var time: Date = Date(); @State private var dur: Int = 0; @State private var photoDataList: [Data] = []
    @State private var didInitialize = false
    private var formattedML: String {
        Formatters.wholeNumber.string(from: NSNumber(value: ml)) ?? "\(ml)"
    }
    var body: some View {
        BaseInputSheet(title: "HYDRATE!", isEditMode: editLog != nil, btnColor: Color(hex: "1C1C1E"), note: $note, logTime: $time, duration: $dur, imageDataList: $photoDataList, action: {
            if let log = editLog { viewModel.updateLog(id: log.id, detail: "\(ml)ml", note: note, duration: dur, imageDataList: photoDataList, date: time) }
            else { viewModel.addLog(type: .water, detail: "\(ml)ml", note: note, duration: dur, imageDataList: photoDataList, date: time) }
        }, deleteAction: editLog.map { log in
            { viewModel.deleteLog(id: log.id) }
        }) {
            VStack(spacing: 16) {
                HStack(spacing: 10) {
                    ForEach(DataSets.waterOptions, id: \.self) { val in
                        Button(action: { ml = val }) {
                            Text("\(val)ml")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(ml == val ? .white : .black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 38)
                                .modernStyle(color: ml == val ? AppTheme.water : AppTheme.lightGray, radius: 100)
                        }
                    }
                }

                WaterWavePicker(ml: $ml)
            }
        }.onAppear(perform: initializeIfNeeded)
    }

    private func initializeIfNeeded() {
        guard !didInitialize else { return }
        didInitialize = true
        time = initialDate
        if let log = editLog {
            ml = log.structuredData.waterML ?? 300
            note = log.note
            photoDataList = log.imageDataList
        }
    }
}

struct WaterWavePicker: View {
    @Binding var ml: Int
    @State private var dragStartValue: Double?
    @State private var dragTranslation: CGFloat = 0
    private let range: ClosedRange<Double> = 0...1500
    private let step: Double = 25
    private let bars = Array(-30...30)
    private let panelHeight: CGFloat = 168
    private let waveHeight: CGFloat = 74

    private var clampedValue: Double {
        min(max(Double(ml), range.lowerBound), range.upperBound)
    }

    var body: some View {
        GeometryReader { proxy in
                let width = proxy.size.width
                let spacing = width / CGFloat(max(bars.count - 1, 1))
                let centerShift = dragTranslation / max(spacing, 1)

                ZStack(alignment: .top) {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    AppTheme.water.opacity(0.04),
                                    AppTheme.water.opacity(0.12),
                                    AppTheme.water.opacity(0.04)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    VStack(spacing: 14) {
                        HStack {
                            Text("0ml")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(AppTheme.black.opacity(0.26))
                            Spacer()
                            Text("1500ml")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(AppTheme.black.opacity(0.26))
                        }

                        scaleLabel(for: clampedValue)

                        ZStack(alignment: .bottom) {
                            HStack(alignment: .bottom, spacing: max(spacing * 0.08, 1.5)) {
                                ForEach(bars, id: \.self) { index in
                                    let shiftedIndex = Double(index) - Double(centerShift * 0.42)
                                    let focus = focusStrength(for: Double(index))
                                    let crest = crestStrength(for: index)
                                    let fade = edgeFade(for: shiftedIndex)
                                    let scale = edgeScale(for: shiftedIndex)
                                    let height = 8 + (focus * 24) + (crest * 42)
                                    let opacity = 0.08 + (focus * 0.62) + (crest * 0.26)

                                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                                        .fill(AppTheme.water.opacity(min(opacity, 0.95)))
                                        .frame(width: max(spacing * 0.52, 3.2), height: height)
                                        .scaleEffect(x: scale, y: scale, anchor: .bottom)
                                        .opacity(fade)
                                }
                            }
                            .offset(x: dragTranslation * 0.18)
                            .animation(.interactiveSpring(response: 0.24, dampingFraction: 0.84), value: dragTranslation)
                            .animation(.interactiveSpring(response: 0.26, dampingFraction: 0.86), value: ml)
                            .frame(height: waveHeight, alignment: .bottom)

                            Capsule(style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.98),
                                            AppTheme.water.opacity(0.88)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 3, height: 68)
                                .shadow(color: AppTheme.water.opacity(0.22), radius: 4, x: 0, y: 1)
                        }
                        .frame(height: waveHeight, alignment: .bottom)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 18)
                    .padding(.bottom, 14)
                }
                .frame(height: panelHeight)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .contentShape(Rectangle())
                .gesture(dragGesture(width: width))
            }
        .frame(height: panelHeight)
        .padding(.bottom, 8)
    }

    private func dragGesture(width: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 2)
            .onChanged { value in
                if dragStartValue == nil {
                    dragStartValue = clampedValue
                }
                dragTranslation = value.translation.width
                let sensitivity = (range.upperBound - range.lowerBound) / max(Double(width) * 1.15, 1)
                let delta = Double(value.translation.width) * sensitivity
                let nextValue = min(max((dragStartValue ?? clampedValue) - delta, range.lowerBound), range.upperBound)
                ml = Int((nextValue / step).rounded() * step)
            }
            .onEnded { _ in
                dragStartValue = nil
                withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                    dragTranslation = 0
                }
            }
    }

    private func scaleLabel(for value: Double) -> some View {
        Text("\(formattedValue(Int(min(max(value, range.lowerBound), range.upperBound))))ml")
            .font(.system(size: 28, weight: .black, design: .rounded))
            .foregroundColor(AppTheme.black)
            .animation(.spring(response: 0.28, dampingFraction: 0.9), value: ml)
    }

    private func focusStrength(for index: Double) -> Double {
        let distance = abs(index)
        return max(0, 1 - distance / 24)
    }

    private func crestStrength(for index: Int) -> Double {
        let cycle = abs(index) % 10
        switch cycle {
        case 0: return 1.0
        case 1, 9: return 0.84
        case 2, 8: return 0.66
        case 3, 7: return 0.5
        case 4, 6: return 0.28
        default: return 0.14
        }
    }

    private func edgeFade(for index: Double) -> Double {
        let distance = abs(index)
        return max(0.18, 1 - distance / 20)
    }

    private func edgeScale(for index: Double) -> CGFloat {
        let distance = abs(index)
        let normalized = max(0, 1 - distance / 22)
        return CGFloat(0.78 + normalized * 0.22)
    }

    private func formattedValue(_ value: Int) -> String {
        Formatters.wholeNumber.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}

// 4.2 饮料 (紧凑胶囊版)
struct DrinkInputSheet: View {
    @EnvironmentObject var viewModel: AppViewModel; var editLog: LogItem?; var initialDate: Date
    @State private var selected: String = "Coffee"; @State private var hasCaffeine = false; @State private var drinkTemperature = "Cold"; @State private var sugarLevel = "Medium"; @State private var note: String = ""; @State private var time: Date = Date(); @State private var dur: Int = 0; @State private var photoDataList: [Data] = []
    @State private var didInitialize = false
    var body: some View {
        BaseInputSheet(title: "CHOOSE POISON", isEditMode: editLog != nil, btnColor: Color(hex: "1C1C1E"), note: $note, logTime: $time, duration: $dur, imageDataList: $photoDataList, action: {
            let structuredData = LogStructuredData(
                drinkType: selected,
                drinkHasCaffeine: hasCaffeine,
                drinkTemperature: drinkTemperature,
                drinkSugarLevel: sugarLevel
            )
            if let log = editLog { viewModel.updateLog(id: log.id, detail: selected, structuredData: structuredData, note: note, duration: dur, imageDataList: photoDataList, date: time) }
            else { viewModel.addLog(type: .drink, detail: selected, structuredData: structuredData, note: note, duration: dur, imageDataList: photoDataList, date: time) }
        }, deleteAction: editLog.map { log in
            { viewModel.deleteLog(id: log.id) }
        }) {
            VStack(alignment: .leading, spacing: 14) {
                FormSectionCard(title: "Drink Type") {
                    LazyVGrid(columns: LayoutMetrics.pairGridColumns, spacing: 10) {
                        ForEach(DataSets.drinks, id: \.0) { drink in
                            Button(action: { selected = drink.0 }) {
                                HStack(spacing: 8) {
                                    Text(drink.1).font(.system(size: 20))
                                    Text(drink.0)
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(selected == drink.0 ? .white : .black)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .modernStyle(color: selected == drink.0 ? AppTheme.drink : .white, radius: 16)
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                    }
                }

                FormSectionCard(title: "Drink Details") {
                    VStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("CAFFEINE")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.gray)
                            LazyVGrid(columns: LayoutMetrics.pairGridColumns, spacing: 10) {
                                ForEach(DataSets.drinkCaffeineOptions, id: \.id) { option in
                                    Button(action: { hasCaffeine = option.id == "yes" }) {
                                        SelectionDetailButton(
                                            icon: option.icon,
                                            title: option.title,
                                            subtitle: option.subtitle,
                                            isSelected: hasCaffeine == (option.id == "yes"),
                                            themeColor: AppTheme.drink,
                                            usesSystemImage: option.usesSystemImage
                                        )
                                    }
                                    .buttonStyle(ScaleButtonStyle())
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("TEMP")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.gray)
                            LazyVGrid(columns: LayoutMetrics.pairGridColumns, spacing: 10) {
                                ForEach(DataSets.drinkTemperatureOptions, id: \.id) { option in
                                    Button(action: { drinkTemperature = option.id }) {
                                        SelectionDetailButton(
                                            icon: option.icon,
                                            title: option.title,
                                            subtitle: option.subtitle,
                                            isSelected: drinkTemperature == option.id,
                                            themeColor: AppTheme.drink,
                                            usesSystemImage: option.usesSystemImage
                                        )
                                    }
                                    .buttonStyle(ScaleButtonStyle())
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("SUGAR")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.gray)
                            LazyVGrid(columns: LayoutMetrics.pairGridColumns, spacing: 10) {
                                ForEach(DataSets.drinkSugarOptions, id: \.id) { option in
                                    Button(action: { sugarLevel = option.id }) {
                                        SelectionDetailButton(
                                            icon: option.icon,
                                            title: option.title,
                                            subtitle: option.subtitle,
                                            isSelected: sugarLevel == option.id,
                                            themeColor: AppTheme.drink,
                                            usesSystemImage: option.usesSystemImage
                                        )
                                    }
                                    .buttonStyle(ScaleButtonStyle())
                                }
                            }
                        }
                    }
                }
            }
        }.onAppear(perform: initializeIfNeeded)
    }

    private func initializeIfNeeded() {
        guard !didInitialize else { return }
        didInitialize = true
        time = initialDate
        if let log = editLog {
            selected = log.structuredData.drinkType ?? log.detail
            hasCaffeine = log.structuredData.drinkHasCaffeine ?? false
            drinkTemperature = log.structuredData.drinkTemperature ?? "Cold"
            sugarLevel = log.structuredData.drinkSugarLevel ?? "Medium"
            note = log.note
            photoDataList = log.imageDataList
        }
    }
}

// 4.3 食物 (紧凑胶囊版)
struct FoodInputSheet: View {
    @EnvironmentObject var viewModel: AppViewModel; var editLog: LogItem?; var initialDate: Date
    @State private var selected: String = "Burger🍔"; @State private var note: String = ""; @State private var time: Date = Date(); @State private var dur: Int = 15; @State private var photoDataList: [Data] = []
    @State private var didInitialize = false
    var body: some View {
        BaseInputSheet(title: "FEED ME", isEditMode: editLog != nil, btnColor: Color(hex: "1C1C1E"), note: $note, logTime: $time, duration: $dur, imageDataList: $photoDataList, showDuration: true, action: {
            if let log = editLog { viewModel.updateLog(id: log.id, detail: selected, note: note, duration: dur, imageDataList: photoDataList, date: time) }
            else { viewModel.addLog(type: .food, detail: selected, note: note, duration: dur, imageDataList: photoDataList, date: time) }
        }, deleteAction: editLog.map { log in
            { viewModel.deleteLog(id: log.id) }
        }) {
            LazyVGrid(columns: LayoutMetrics.pairGridColumns, spacing: 10) {
                ForEach(DataSets.foods, id: \.0) { food in Button(action: { selected = food.0 }) { Text(food.0).font(.system(size: 15, weight: .bold)).foregroundColor(selected == food.0 ? .white : .black).frame(maxWidth: .infinity).frame(height: 46).modernStyle(color: selected == food.0 ? AppTheme.food : AppTheme.lightGray, radius: 100) }.buttonStyle(ScaleButtonStyle()) }
            }
        }.onAppear(perform: initializeIfNeeded)
    }

    private func initializeIfNeeded() {
        guard !didInitialize else { return }
        didInitialize = true
        time = initialDate
        if let log = editLog {
            selected = log.structuredData.foodType ?? log.detail
            note = log.note
            dur = log.duration
            photoDataList = log.imageDataList
        }
    }
}

// 4.4 排泄 (紧凑方块版)
struct PoopInputSheet: View {
    @EnvironmentObject var viewModel: AppViewModel; var editLog: LogItem?; var initialDate: Date
    @State private var selectedShapeID: String = "poop_4"; @State private var selectedColorID: String = PoopOptionResolver.defaultColorID; @State private var selectedSymptomID: String = "comfortable"; @State private var note: String = ""; @State private var time: Date = Date(); @State private var dur: Int = 5; @State private var photoDataList: [Data] = []
    @State private var didInitialize = false
    var body: some View {
        BaseInputSheet(title: "CAPTAIN'S LOG", isEditMode: editLog != nil, btnColor: Color(hex: "1C1C1E"), note: $note, logTime: $time, duration: $dur, imageDataList: $photoDataList, showDuration: true, showPhotoPicker: false, action: {
            let detailValue = PoopRecordValue(shapeID: selectedShapeID, colorID: selectedColorID).detailValue
            let structuredData = LogStructuredData(
                poopShapeID: selectedShapeID,
                poopColorID: selectedColorID,
                poopSymptomID: selectedSymptomID
            )
            if let log = editLog { viewModel.updateLog(id: log.id, detail: detailValue, structuredData: structuredData, note: note, duration: dur, imageDataList: photoDataList, date: time) }
            else { viewModel.addLog(type: .poop, detail: detailValue, structuredData: structuredData, note: note, duration: dur, imageDataList: photoDataList, date: time) }
        }, deleteAction: editLog.map { log in
            { viewModel.deleteLog(id: log.id) }
        }) {
            VStack(alignment: .leading, spacing: 14) {
                FormSectionCard(title: "Shape") {
                    LazyVGrid(columns: LayoutMetrics.poopGridColumns, spacing: 10) {
                        ForEach(DataSets.poops, id: \.id) { poop in
                            Button(action: { selectedShapeID = poop.id }) {
                                ZStack {
                                    if let image = PoopAssetLoader.image(named: poop.imageName) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFit()
                                            .padding(8)
                                    } else {
                                        Text(poop.id)
                                            .font(.system(size: 12, weight: .bold))
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .aspectRatio(1, contentMode: .fit)
                                .modernStyle(color: selectedShapeID == poop.id ? AppTheme.poop : .white, radius: 16)
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                    }
                }

                FormSectionCard(title: "Color") {
                    LazyVGrid(columns: LayoutMetrics.poopGridColumns, spacing: 10) {
                        ForEach(DataSets.poopColors, id: \.id) { poopColor in
                            Button(action: { selectedColorID = poopColor.id }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(selectedColorID == poopColor.id ? AppTheme.poop.opacity(0.22) : Color.white)
                                    Circle()
                                        .fill(poopColor.color)
                                        .frame(width: 26, height: 26)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(selectedColorID == poopColor.id ? AppTheme.poop : Color.clear, lineWidth: 2)
                                )
                            }
                            .buttonStyle(ScaleButtonStyle())
                            .accessibilityLabel(Text(poopColor.label))
                        }
                    }
                }

                FormSectionCard(title: "Symptoms") {
                    LazyVGrid(columns: LayoutMetrics.pairGridColumns, spacing: 10) {
                        ForEach(DataSets.poopSymptoms, id: \.id) { symptom in
                            Button(action: { selectedSymptomID = symptom.id }) {
                                HStack(spacing: 8) {
                                    Text(symptom.emoji)
                                        .font(.system(size: 18))
                                    Text(symptom.label)
                                        .font(.system(size: 13, weight: .bold))
                                }
                                .foregroundColor(selectedSymptomID == symptom.id ? .white : .black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .modernStyle(color: selectedSymptomID == symptom.id ? AppTheme.poop : .white, radius: 16)
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                    }
                }
            }
        }.onAppear(perform: initializeIfNeeded)
    }

    private func initializeIfNeeded() {
        guard !didInitialize else { return }
        didInitialize = true
        time = initialDate
        if let log = editLog {
            selectedShapeID = log.structuredData.poopShapeID ?? "poop_4"
            selectedColorID = log.structuredData.poopColorID ?? PoopOptionResolver.defaultColorID
            selectedSymptomID = log.structuredData.resolvedPoopSymptomID ?? "comfortable"
            note = log.note
            dur = log.duration
            photoDataList = log.imageDataList
        }
    }
}

// MARK: - 5. Dashboard 与 列表组件 保持原样 (节约篇幅)
struct DashboardView: View {
    @EnvironmentObject var viewModel: AppViewModel; @Environment(\.dismiss) var dismiss; @State private var activeSheet: SheetContext? = nil
    var showBackButton: Bool = true
    var body: some View {
        let todayLogs = viewModel.logs(for: Date())
        let waterTotal = todayLogs.reduce(0) { $0 + ($1.structuredData.waterML ?? 0) }
        let drinkCount = todayLogs.filter { $0.type == .drink }.count
        let poopCount = todayLogs.filter { $0.type == .poop }.count
        ZStack {
            Color.white.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    if showBackButton {
                        HStack { Button(action: { dismiss() }) { Image(systemName: "arrow.left").font(.system(size: 20, weight: .bold)).foregroundColor(.black).padding(14).background(AppTheme.lightGray).clipShape(Circle()) }; Spacer() }.padding(.top, 10).padding(.horizontal, 24)
                    } else {
                        Spacer().frame(height: 10)
                    }
                    VStack(alignment: .leading, spacing: 14) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("TODAY!")
                                .font(.system(size: 34, weight: .black, design: .rounded))
                            Text("今天过得像个人样吗？")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.gray.opacity(0.86))
                        }

                        HStack(spacing: 10) {
                            CardMetaPill(
                                text: "\(todayLogs.count) logs",
                                foregroundColor: AppTheme.black,
                                backgroundColor: AppTheme.lightGray
                            )
                            CardMetaPill(
                                text: "\(waterTotal)ml water",
                                foregroundColor: AppTheme.water,
                                backgroundColor: AppTheme.water.opacity(0.12)
                            )
                            if drinkCount > 0 {
                                CardMetaPill(
                                    text: "\(drinkCount) drinks",
                                    foregroundColor: AppTheme.drink,
                                    backgroundColor: AppTheme.drink.opacity(0.12)
                                )
                            }
                            if poopCount > 0 {
                                CardMetaPill(
                                    text: "\(poopCount) poop",
                                    foregroundColor: AppTheme.black,
                                    backgroundColor: AppTheme.poop.opacity(0.28)
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 24)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("TODAY'S LOGS")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.black)

                        if todayLogs.isEmpty {
                            Text("No logs today.")
                                .foregroundColor(.gray)
                        } else {
                            LazyVStack(spacing: 16) {
                                ForEach(todayLogs) { log in
                                    Button(action: { activeSheet = .edit(log) }) {
                                        LogRowView(log: log)
                                    }
                                    .buttonStyle(ScaleButtonStyle())
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 4)
                    .padding(.bottom, 156)
                }
            }
            VStack {
                Spacer()
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "text.bubble.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppTheme.black.opacity(0.7))
                        .padding(10)
                        .background(Color.white.opacity(0.72))
                        .clipShape(Circle())
                    Text(viewModel.aiJudgeText)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                .shadow(color: Color.black.opacity(0.08), radius: 20, y: 10)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .ignoresSafeArea(.keyboard)
        }
        .navigationBarHidden(true)
        .sheet(item: $activeSheet) { context in
            InputSheetRouter(context: context)
                .presentationDetents([.height(context.sheetHeight)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
                .presentationBackground(.white)
        }
    }
}

struct LogRowView: View {
    let log: LogItem
    private let timeText: String
    private let image: UIImage?
    private let poopImage: UIImage?
    private let poopColor: PoopColorOption?

    init(log: LogItem) {
        self.log = log
        self.timeText = Formatters.logTime.string(from: log.date)
        self.image = log.imageData.flatMap(ImageDecoder.image(from:))
        let poopRecord = log.type == .poop ? PoopRecordValue(shapeID: log.structuredData.poopShapeID ?? "poop_4", colorID: log.structuredData.poopColorID ?? PoopOptionResolver.defaultColorID) : nil
        self.poopImage = poopRecord.flatMap { record in
            DataSets.poops.first(where: { $0.id == record.shapeID }).flatMap { PoopAssetLoader.image(named: $0.imageName) }
        }
        self.poopColor = poopRecord?.colorOption
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(log.type.icon)
                    .font(.system(size: 23))
                    .padding(11)
                    .background(Color.white.opacity(0.24))
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: 3) {
                    Text(log.type.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(log.type == .poop ? .black : .white)
                    Text(timeText)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(log.type == .poop ? .black.opacity(0.6) : .white.opacity(0.8))
                }
                Spacer()
                if log.duration > 0 {
                    CardMetaPill(
                        text: "\(log.duration) min",
                        foregroundColor: log.type == .poop ? AppTheme.black : .white,
                        backgroundColor: log.type == .poop ? Color.white.opacity(0.72) : Color.white.opacity(0.18)
                    )
                }
            }

            if let poopImage {
                HStack(spacing: 8) {
                    Image(uiImage: poopImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 46, height: 32)
                    if let poopColor {
                        Circle()
                            .fill(poopColor.color)
                            .frame(width: 14, height: 14)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.white)
                .cornerRadius(100)
            } else {
                CardPrimaryValue(
                    text: log.primaryDisplayText,
                    foregroundColor: log.type == .poop ? AppTheme.black : .white,
                    backgroundColor: log.type == .poop ? Color.white.opacity(0.9) : Color.white.opacity(0.18),
                    style: log.primaryValueStyle
                )
            }

            if !log.drinkSummaryTags.isEmpty || !log.poopSymptomTags.isEmpty || !log.note.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    if !log.drinkSummaryTags.isEmpty {
                        InfoTagWrap(
                            tags: log.drinkSummaryTags,
                            foregroundColor: log.type == .poop ? AppTheme.black : .white,
                            backgroundColor: log.type == .poop ? Color.white.opacity(0.72) : Color.white.opacity(0.22)
                        )
                    }
                    if !log.poopSymptomTags.isEmpty {
                        InfoTagWrap(
                            tags: log.poopSymptomTags,
                            foregroundColor: AppTheme.black,
                            backgroundColor: Color.white.opacity(0.72)
                        )
                    }
                    if !log.note.isEmpty {
                        Text("Note: \(log.note)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(log.type == .poop ? .black.opacity(0.76) : .white.opacity(0.88))
                            .lineLimit(3)
                    }
                }
            }
            if let image { Image(uiImage: image).resizable().scaledToFill().frame(height: 140).frame(maxWidth: .infinity).clipShape(RoundedRectangle(cornerRadius: 16)) }
        }.padding(15).modernStyle(color: log.type.color, radius: 28)
    }
}

// MARK: - 6. 日历看板
struct VibeCalendarView: View {
    @EnvironmentObject var viewModel: AppViewModel; @Environment(\.dismiss) var dismiss; @State private var currentDate = Date(); @State private var selectedDate = Calendar.current.startOfDay(for: Date()); @State private var activeSheet: SheetContext? = nil
    var showBackButton: Bool = true
    let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    private let calendar = Calendar.current
    var body: some View {
        let days = viewModel.generateCalendarGrid(for: currentDate)
        let monthDays = days.compactMap { $0 }
        ZStack {
            Color.white.ignoresSafeArea()
            VStack(spacing: 20) {
                HStack {
                    if showBackButton {
                        Button(action: { dismiss() }) { Image(systemName: "arrow.left").font(.system(size: 20, weight: .bold)).foregroundColor(.black).padding(14).background(AppTheme.lightGray).clipShape(Circle()) }
                    }
                    Spacer()
                    HStack(spacing: 14) {
                        Button(action: { changeMonth(by: -1) }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 15, weight: .black))
                                .foregroundColor(.black)
                                .frame(width: 34, height: 34)
                                .background(AppTheme.lightGray)
                                .clipShape(Circle())
                        }
                        Text(monthYearString(from: currentDate))
                            .font(.system(size: 19, weight: .black, design: .rounded))
                            .frame(width: 126)
                        Button(action: { changeMonth(by: 1) }) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 15, weight: .black))
                                .foregroundColor(.black)
                                .frame(width: 34, height: 34)
                                .background(AppTheme.lightGray)
                                .clipShape(Circle())
                        }
                    }
                }.padding(.horizontal, 24).padding(.top, 10)
                HStack { ForEach(daysOfWeek, id: \.self) { day in Text(day).font(.system(size: 12, weight: .bold)).foregroundColor(.gray).frame(maxWidth: .infinity) } }.padding(.horizontal, 16)
                LazyVGrid(columns: LayoutMetrics.calendarColumns, spacing: 10) {
                    ForEach(days.indices, id: \.self) { index in
                        if let date = days[index] {
                            let vibe = viewModel.mockAIVibe(for: date)
                            let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                            Button(action: { selectedDate = calendar.startOfDay(for: date) }) { ZStack { if isSelected { AppTheme.black } else if let vibe = vibe { vibe.color } else { AppTheme.lightGray }; Text("\(Calendar.current.component(.day, from: date))").font(.system(size: 17, weight: .bold, design: .rounded)).foregroundColor((vibe != nil || isSelected) ? .white : .gray) }.cornerRadius(12).aspectRatio(1, contentMode: .fit) }.buttonStyle(ScaleButtonStyle())
                        } else { Color.clear.aspectRatio(1, contentMode: .fit) }
                    }
                }.padding(.horizontal, 16)

                CalendarRecordsPager(
                    days: monthDays,
                    selectedDate: $selectedDate,
                    onAddLog: { activeSheet = .new($0, selectedDate) },
                    onEditLog: { activeSheet = .edit($0) }
                )
                    .environmentObject(viewModel)
                    .frame(maxHeight: .infinity)
                    .padding(.top, 4)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            selectedDate = calendar.startOfDay(for: selectedDate)
            currentDate = selectedDate
        }
        .sheet(item: $activeSheet) { context in
            InputSheetRouter(context: context)
                .presentationDetents([.height(context.sheetHeight)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
                .presentationBackground(.white)
        }
    }
    func changeMonth(by value: Int) {
        let newMonth = Calendar.current.date(byAdding: .month, value: value, to: currentDate) ?? Date()
        currentDate = newMonth
        let components = Calendar.current.dateComponents([.year, .month], from: newMonth)
        selectedDate = Calendar.current.date(from: components) ?? newMonth
    }
    func monthYearString(from date: Date) -> String { Formatters.monthYear.string(from: date).uppercased() }
}

struct StatsView: View {
    @EnvironmentObject var viewModel: AppViewModel
    private let calendar = Calendar.current
    @State private var selectedRange: StatsRange = .week
    @State private var activeDetailContext: StatsDetailContext?

    var body: some View {
        let today = Date()
        let rangeStart = calendar.date(byAdding: .day, value: -(selectedRange.days - 1), to: calendar.startOfDay(for: today)) ?? today
        let rangeEnd = today
        let countsByType = viewModel.logsGroupedByType(from: rangeStart, to: rangeEnd)
        let poopLogs = viewModel.poopLogs(from: rangeStart, to: rangeEnd)
        let totalRecords = countsByType.values.reduce(0, +)
        let waterSeries = viewModel.waterSeries(from: rangeStart, to: rangeEnd)
        let poopShapeCounts = viewModel.poopShapeCounts(from: rangeStart, to: rangeEnd)
        let poopColorCounts = viewModel.poopColorCounts(from: rangeStart, to: rangeEnd)
        let hydrationHitRate = viewModel.hydrationGoalHitRate(from: rangeStart, to: rangeEnd, goalML: viewModel.hydrationGoalML)
        let streakDays = viewModel.consecutiveLoggingDays(through: today)
        let averageDailyWater = viewModel.averageDailyWater(from: rangeStart, to: rangeEnd)
        let bestWaterDay = viewModel.bestWaterDay(from: rangeStart, to: rangeEnd)
        let lowestWaterDay = viewModel.lowestWaterDay(from: rangeStart, to: rangeEnd)

        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("STATS")
                        .font(.system(size: 34, weight: .black, design: .rounded))
                    Text("核心数据先做基础统计，不做复杂分析。")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 24)
                .padding(.top, 18)

                Picker("Stats Range", selection: $selectedRange) {
                    ForEach(StatsRange.allCases, id: \.self) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 24)

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("喝水目标")
                            .font(.system(size: 18, weight: .black, design: .rounded))
                        Spacer()
                        Text("\(viewModel.hydrationGoalML)ml")
                            .font(.system(size: 20, weight: .black, design: .rounded))
                            .foregroundColor(AppTheme.water)
                    }

                    HStack(spacing: 12) {
                        Button(action: {
                            viewModel.updateHydrationGoalML(max(500, viewModel.hydrationGoalML - 250))
                        }) {
                            Image(systemName: "minus")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(AppTheme.black)
                                .frame(width: 42, height: 42)
                                .background(AppTheme.lightGray)
                                .clipShape(Circle())
                        }
                        .buttonStyle(ScaleButtonStyle())

                        Slider(
                            value: Binding(
                                get: { Double(viewModel.hydrationGoalML) },
                                set: { newValue in
                                    let roundedValue = Int((newValue / 250).rounded() * 250)
                                    viewModel.updateHydrationGoalML(min(max(roundedValue, 500), 4000))
                                }
                            ),
                            in: 500...4000,
                            step: 250
                        )
                        .tint(AppTheme.water)

                        Button(action: {
                            viewModel.updateHydrationGoalML(min(4000, viewModel.hydrationGoalML + 250))
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 42, height: 42)
                                .background(AppTheme.water)
                                .clipShape(Circle())
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }

                    Text("范围 500ml - 4000ml，步进 250ml")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.gray)
                }
                .padding(18)
                .background(AppTheme.water.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .padding(.horizontal, 24)

                LazyVGrid(columns: LayoutMetrics.pairGridColumns, spacing: 14) {
                    StatsCard(
                        title: "今日喝水",
                        value: "\(viewModel.totalWater(on: today))ml",
                        subtitle: "目标 \(viewModel.hydrationGoalML)ml",
                        color: AppTheme.water
                    )
                    StatsCard(
                        title: "\(selectedRange.rawValue)记录",
                        value: "\(totalRecords)",
                        subtitle: "所有类型总次数",
                        color: AppTheme.black
                    )
                    StatsCard(
                        title: "\(selectedRange.rawValue)排便",
                        value: "\(poopLogs.count)",
                        subtitle: "用于观察频次",
                        color: AppTheme.poop
                    )
                    StatsCard(
                        title: "今日记录数",
                        value: "\(viewModel.logCount(for: today))",
                        subtitle: "当前日期全部记录",
                        color: AppTheme.food
                    )
                    StatsCard(
                        title: "连续记录",
                        value: "\(streakDays)天",
                        subtitle: "截至今天的连续天数",
                        color: AppTheme.drink
                    )
                    StatsCard(
                        title: "喝水达标率",
                        value: "\(Int((hydrationHitRate * 100).rounded()))%",
                        subtitle: "\(selectedRange.rawValue)达到 \(viewModel.hydrationGoalML)ml",
                        color: AppTheme.water
                    )
                }
                .padding(.horizontal, 24)

                VStack(alignment: .leading, spacing: 12) {
                    Text("\(selectedRange.rawValue)喝水趋势")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                    WaterTrendCard(series: waterSeries) { date in
                        activeDetailContext = .day(date)
                    }
                }
                .padding(.horizontal, 24)

                VStack(alignment: .leading, spacing: 12) {
                    Text("\(selectedRange.rawValue)喝水摘要")
                        .font(.system(size: 18, weight: .black, design: .rounded))

                    HStack(alignment: .top, spacing: 14) {
                        SummaryMetricCard(
                            title: "平均每日",
                            value: "\(averageDailyWater)ml",
                            subtitle: "按当前区间天数平均"
                        )
                        SummaryMetricCard(
                            title: "最佳一天",
                            value: bestWaterDay.map { "\($0.totalML)ml" } ?? "0ml",
                            subtitle: bestWaterDay.map { shortStatsLabel(for: $0.date) } ?? "-"
                        )
                        SummaryMetricCard(
                            title: "最低一天",
                            value: lowestWaterDay.map { "\($0.totalML)ml" } ?? "0ml",
                            subtitle: lowestWaterDay.map { shortStatsLabel(for: $0.date) } ?? "-"
                        )
                    }
                }
                .padding(.horizontal, 24)

                VStack(alignment: .leading, spacing: 12) {
                    Text("\(selectedRange.rawValue)类型分布")
                        .font(.system(size: 18, weight: .black, design: .rounded))

                    ForEach(LogType.allCases, id: \.self) { type in
                        let count = countsByType[type, default: 0]
                        Button(action: {
                            guard count > 0 else { return }
                            activeDetailContext = .type(type, rangeStart, rangeEnd)
                        }) {
                            HStack(spacing: 12) {
                                Text(type.icon)
                                    .font(.system(size: 22))
                                    .frame(width: 28)
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(type.title)
                                            .font(.system(size: 14, weight: .bold))
                                        Spacer()
                                        Text("\(count)")
                                            .font(.system(size: 14, weight: .black))
                                    }

                                    GeometryReader { proxy in
                                        ZStack(alignment: .leading) {
                                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                                .fill(AppTheme.lightGray)
                                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                                .fill(type.color)
                                                .frame(width: max(proxy.size.width * CGFloat(totalRecords == 0 ? 0 : Double(count) / Double(totalRecords)), totalRecords == 0 ? 0 : 12))
                                        }
                                    }
                                    .frame(height: 10)
                                }
                            }
                            .padding(14)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                }
                .padding(18)
                .background(AppTheme.lightGray)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .padding(.horizontal, 24)

                HStack(alignment: .top, spacing: 14) {
                    DistributionCard(
                        title: "排便形状分布",
                        rows: DataSets.poops.map { poop in
                            let count = poopShapeCounts[poop.id, default: 0]
                            return DistributionRow(icon: poop.id, imageName: poop.imageName, color: nil, value: count)
                        },
                        onSelectRow: { row in
                            guard let shapeID = row.icon, row.value > 0 else { return }
                            activeDetailContext = .poopShape(shapeID, rangeStart, rangeEnd)
                        }
                    )
                    DistributionCard(
                        title: "排便颜色分布",
                        rows: DataSets.poopColors.map { poopColor in
                            let count = poopColorCounts[poopColor.id, default: 0]
                            return DistributionRow(icon: poopColor.id, imageName: nil, color: poopColor.color, value: count)
                        },
                        onSelectRow: { row in
                            guard let colorID = row.icon, row.value > 0 else { return }
                            activeDetailContext = .poopColor(colorID, rangeStart, rangeEnd)
                        }
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .background(Color.white.ignoresSafeArea())
        .sheet(item: $activeDetailContext) { context in
            StatsLogsSheet(context: context)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
                .presentationBackground(.white)
        }
    }

    private func shortStatsLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }
}

struct StatsCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.gray)
            Text(value)
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundColor(color == AppTheme.poop ? AppTheme.black : color)
            Text(subtitle)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.gray)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, minHeight: 122, alignment: .topLeading)
        .padding(16)
        .background(color.opacity(color == AppTheme.black ? 0.08 : 0.14))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

struct SummaryMetricCard: View {
    let title: String
    let value: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.gray)
            Text(value)
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundColor(AppTheme.black)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(subtitle)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.gray)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, minHeight: 118, alignment: .topLeading)
        .padding(14)
        .background(AppTheme.lightGray)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

struct WaterTrendCard: View {
    let series: [(date: Date, totalML: Int)]
    let onSelectDate: (Date) -> Void

    var body: some View {
        let maxValue = max(series.map(\.totalML).max() ?? 0, 1)

        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .lastTextBaseline) {
                Text("\(series.map(\.totalML).reduce(0, +))ml")
                    .font(.system(size: 26, weight: .black, design: .rounded))
                Text("累计")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.gray)
            }

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(Array(series.enumerated()), id: \.offset) { _, item in
                    Button(action: {
                        onSelectDate(item.date)
                    }) {
                        VStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 7, style: .continuous)
                                .fill(item.totalML == 0 ? AppTheme.lightGray : AppTheme.water)
                                .frame(height: max(10, CGFloat(item.totalML) / CGFloat(maxValue) * 120))

                            Text(shortLabel(for: item.date))
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .bottom)
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
            .frame(height: 150, alignment: .bottom)
        }
        .padding(18)
        .background(AppTheme.water.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private func shortLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }
}

struct StatsLogsSheet: View {
    let context: StatsDetailContext
    @EnvironmentObject var viewModel: AppViewModel
    @State private var activeSheet: SheetContext? = nil
    private let calendar = Calendar.current

    var body: some View {
        let records = resolvedLogs

        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()

                if records.isEmpty {
                    VStack(spacing: 10) {
                        Text("No matching records.")
                            .font(.system(size: 18, weight: .black, design: .rounded))
                        Text("当前筛选条件下没有可展示的数据。")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(records) { log in
                                Button(action: { activeSheet = .edit(log) }) {
                                    LogRowView(log: log)
                                }
                                .buttonStyle(ScaleButtonStyle())
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 18)
                    }
                }
            }
            .navigationTitle(sheetTitle)
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(item: $activeSheet) { context in
            InputSheetRouter(context: context)
                .presentationDetents([.height(context.sheetHeight)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
                .presentationBackground(.white)
        }
    }

    private var resolvedLogs: [LogItem] {
        switch context {
        case .day(let date):
            return viewModel.logs(for: date)
        case .type(let type, let startDate, let endDate):
            return viewModel.logs(of: type, from: startDate, to: endDate)
        case .poopShape(let shapeID, let startDate, let endDate):
            return viewModel.poopLogs(shapeID: shapeID, from: startDate, to: endDate)
        case .poopColor(let colorID, let startDate, let endDate):
            return viewModel.poopLogs(colorID: colorID, from: startDate, to: endDate)
        }
    }

    private var sheetTitle: String {
        switch context {
        case .day(let date):
            return Formatters.fullDate.string(from: date)
        case .type(let type, let startDate, let endDate):
            return "\(type.title) · \(shortRange(startDate, endDate))"
        case .poopShape(let shapeID, let startDate, let endDate):
            return "POOP SHAPE · \(shapeID) · \(shortRange(startDate, endDate))"
        case .poopColor(let colorID, let startDate, let endDate):
            return "POOP COLOR · \(colorID) · \(shortRange(startDate, endDate))"
        }
    }

    private func shortRange(_ startDate: Date, _ endDate: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }
}

struct DistributionRow: Hashable {
    let icon: String?
    let imageName: String?
    let color: Color?
    let value: Int
}

struct DistributionCard: View {
    let title: String
    let rows: [DistributionRow]
    var onSelectRow: ((DistributionRow) -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 16, weight: .black, design: .rounded))

            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                Button(action: {
                    onSelectRow?(row)
                }) {
                    HStack(spacing: 10) {
                        if let imageName = row.imageName, let image = PoopAssetLoader.image(named: imageName) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 28, height: 20)
                        } else if let color = row.color {
                            Circle()
                                .fill(color)
                                .frame(width: 16, height: 16)
                        } else if let icon = row.icon {
                            Text(icon)
                                .font(.system(size: 12, weight: .bold))
                                .frame(width: 28, height: 20)
                        }

                        Spacer()

                        Text("\(row.value)")
                            .font(.system(size: 14, weight: .black))
                    }
                    .padding(.vertical, 2)
                }
                .buttonStyle(ScaleButtonStyle())
                .disabled(row.value == 0 || onSelectRow == nil)
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(16)
        .background(AppTheme.lightGray)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

struct CalendarRecordsPager: View {
    let days: [Date]
    @Binding var selectedDate: Date
    let onAddLog: (LogType) -> Void
    let onEditLog: (LogItem) -> Void
    @EnvironmentObject var viewModel: AppViewModel

    var body: some View {
        let dayLogs = viewModel.logs(for: selectedDate)
        let waterTotal = dayLogs.reduce(0) { $0 + ($1.structuredData.waterML ?? 0) }
        let drinkCount = dayLogs.filter { $0.type == .drink }.count
        let poopCount = dayLogs.filter { $0.type == .poop }.count

        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("RECORDS")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.gray)
                    Text(Formatters.fullDate.string(from: selectedDate))
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundColor(AppTheme.black)
                }
                Spacer()
                CardMetaPill(
                    text: "\(dayLogs.count) logs",
                    foregroundColor: .white,
                    backgroundColor: AppTheme.black
                )
            }
            .padding(.horizontal, 24)

            HStack(spacing: 8) {
                CardMetaPill(
                    text: "\(waterTotal)ml water",
                    foregroundColor: AppTheme.water,
                    backgroundColor: AppTheme.water.opacity(0.12)
                )
                if drinkCount > 0 {
                    CardMetaPill(
                        text: "\(drinkCount) drinks",
                        foregroundColor: AppTheme.drink,
                        backgroundColor: AppTheme.drink.opacity(0.12)
                    )
                }
                if poopCount > 0 {
                    CardMetaPill(
                        text: "\(poopCount) poop",
                        foregroundColor: AppTheme.black,
                        backgroundColor: AppTheme.poop.opacity(0.28)
                    )
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 24)

            HStack(spacing: 10) {
                ForEach(LogType.allCases, id: \.self) { type in
                    Button(action: { onAddLog(type) }) {
                        Text(type.icon)
                            .font(.system(size: 22))
                            .frame(maxWidth: .infinity)
                            .frame(height: 46)
                            .background(type.color.opacity(type == .poop ? 0.32 : 0.18))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
            .padding(.horizontal, 24)

            TabView(selection: $selectedDate) {
                ForEach(days, id: \.timeIntervalSinceReferenceDate) { date in
                    DailyInlineRecordsView(date: date, onEditLog: onEditLog)
                        .tag(Calendar.current.startOfDay(for: date))
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
    }
}

struct DailyInlineRecordsView: View {
    let date: Date
    let onEditLog: (LogItem) -> Void
    @EnvironmentObject var viewModel: AppViewModel

    var body: some View {
        let dayLogs = viewModel.logs(for: date)
        Group {
            if dayLogs.isEmpty {
                VStack(spacing: 10) {
                    Spacer(minLength: 0)
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.gray.opacity(0.36))
                    Text("No records this day.")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.gray.opacity(0.58))
                    Text("Swipe left or right to browse another date.")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.gray.opacity(0.45))
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVGrid(columns: LayoutMetrics.pairGridColumns, spacing: 14) {
                        ForEach(dayLogs) { log in
                            Button(action: { onEditLog(log) }) {
                                CalendarLogCardView(log: log)
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 30)
                }
            }
        }
    }
}

struct CalendarLogCardView: View {
    let log: LogItem
    private let timeText: String
    private let image: UIImage?
    private let poopImage: UIImage?
    private let poopColor: PoopColorOption?

    init(log: LogItem) {
        self.log = log
        self.timeText = Formatters.logTime.string(from: log.date)
        self.image = log.imageData.flatMap(ImageDecoder.image(from:))
        let poopRecord = log.type == .poop ? PoopRecordValue(shapeID: log.structuredData.poopShapeID ?? "poop_4", colorID: log.structuredData.poopColorID ?? PoopOptionResolver.defaultColorID) : nil
        self.poopImage = poopRecord.flatMap { record in
            DataSets.poops.first(where: { $0.id == record.shapeID }).flatMap { PoopAssetLoader.image(named: $0.imageName) }
        }
        self.poopColor = poopRecord?.colorOption
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    HStack(spacing: 8) {
                        Text(log.type.icon)
                            .font(.system(size: 21))
                        Text(log.type.title)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AppTheme.black.opacity(0.7))
                            .lineLimit(1)
                    }
                    Spacer(minLength: 8)
                    VStack(alignment: .trailing, spacing: 6) {
                        Text(timeText)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.gray)
                        if log.duration > 0 {
                            CardMetaPill(
                                text: "\(log.duration) min",
                                foregroundColor: AppTheme.black,
                                backgroundColor: Color.white.opacity(0.9)
                            )
                        }
                    }
                }

                if let poopImage {
                    HStack(spacing: 8) {
                        Image(uiImage: poopImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 42)
                        if let poopColor {
                            Circle()
                                .fill(poopColor.color)
                                .frame(width: 14, height: 14)
                        }
                    }
                } else {
                    CardPrimaryValue(
                        text: log.primaryDisplayText,
                        foregroundColor: AppTheme.black,
                        backgroundColor: Color.white.opacity(0.9),
                        style: log.primaryValueStyle
                    )
                }

                if !log.drinkSummaryTags.isEmpty || !log.poopSymptomTags.isEmpty || !log.note.isEmpty {
                    VStack(alignment: .leading, spacing: 7) {
                        if !log.drinkSummaryTags.isEmpty {
                            InfoTagWrap(
                                tags: log.drinkSummaryTags,
                                foregroundColor: AppTheme.black,
                                backgroundColor: Color.white.opacity(0.9)
                            )
                        }

                        if !log.poopSymptomTags.isEmpty {
                            InfoTagWrap(
                                tags: log.poopSymptomTags,
                                foregroundColor: AppTheme.black,
                                backgroundColor: Color.white.opacity(0.9)
                            )
                        }

                        if !log.note.isEmpty {
                            Text(log.note)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.gray)
                                .lineLimit(2)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .padding(15)
            .background(log.type.color.opacity(log.type == .poop ? 0.28 : 0.18))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 52, height: 52)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .padding(12)
            }
        }
    }
}

struct DateWrapper: Identifiable {
    let date: Date
    var id: TimeInterval { date.timeIntervalSinceReferenceDate }
}

struct DailyDetailSheet: View {
    let date: Date; @EnvironmentObject var viewModel: AppViewModel; @State private var activeSheet: SheetContext? = nil
    var formattedDateString: String { Formatters.fullDate.string(from: date) }
    var body: some View {
        let dayLogs = viewModel.logs(for: date)
        ZStack {
            Color.white.ignoresSafeArea()
            VStack(spacing: 20) {
                RoundedRectangle(cornerRadius: 3).fill(Color.gray.opacity(0.3)).frame(width: 40, height: 5).padding(.top, 10)
                Text(formattedDateString).font(.system(size: 28, weight: .black, design: .rounded))
                HStack(spacing: 15) { ForEach(LogType.allCases, id: \.self) { type in Button(action: { activeSheet = .new(type, date) }) { Text(type.icon).font(.system(size: 24)).frame(maxWidth: .infinity).padding(.vertical, 12).modernStyle(color: type.color.opacity(0.2), radius: 15) }.buttonStyle(ScaleButtonStyle()) } }.padding(.horizontal, 24)
                Text("RECORDS").font(.system(size: 14, weight: .bold)).foregroundColor(.gray).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 24)
                if dayLogs.isEmpty { Spacer(); Text("Nothing logged this day.").font(.system(size: 17, weight: .semibold)).foregroundColor(.gray.opacity(0.5)); Spacer() }
                else { ScrollView { LazyVStack(spacing: 16) { ForEach(dayLogs) { log in Button(action: { activeSheet = .edit(log) }) { LogRowView(log: log) }.buttonStyle(ScaleButtonStyle()) } }.padding(.horizontal, 24).padding(.bottom, 30) } }
            }
        }
        .sheet(item: $activeSheet) { context in
            InputSheetRouter(context: context)
                .presentationDetents([.height(context.sheetHeight)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
                .presentationBackground(.white)
        }
    }
}

// MARK: - 工具类
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0; Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

private extension Array {
    func insertionIndex(
        of newElement: Element,
        using areInIncreasingOrder: (Element, Element) -> Bool
    ) -> Int {
        var low = 0
        var high = count
        while low < high {
            let mid = (low + high) / 2
            if areInIncreasingOrder(self[mid], newElement) {
                low = mid + 1
            } else {
                high = mid
            }
        }
        return low
    }
}

private struct MonthCacheKey: Hashable {
    let year: Int
    let month: Int

    init(date: Date, calendar: Calendar) {
        let components = calendar.dateComponents([.year, .month], from: date)
        self.year = components.year ?? 0
        self.month = components.month ?? 0
    }
}
