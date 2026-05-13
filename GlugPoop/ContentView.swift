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

// MARK: - 1. 数据模型与状态管理
struct LogItem: Identifiable, Hashable {
    let id: UUID
    let type: LogType
    let detail: String
    let note: String
    let duration: Int
    let imageDataList: [Data]
    let date: Date
    var imageData: Data? { imageDataList.first }
    
    init(id: UUID = UUID(), type: LogType, detail: String, note: String, duration: Int, imageDataList: [Data], date: Date) {
        self.id = id; self.type = type; self.detail = detail; self.note = note; self.duration = duration; self.imageDataList = imageDataList; self.date = date
    }
}

enum LogType: CaseIterable {
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
    private let calendar = Calendar.current
    private var logsByDay: [Date: [LogItem]] = [:]
    private var calendarGridCache: [MonthCacheKey: [Date?]] = [:]

    init() { prefillDummyData() }
    
    func addLog(type: LogType, detail: String, note: String, duration: Int, imageDataList: [Data], date: Date) {
        let newLog = LogItem(type: type, detail: detail, note: note, duration: duration, imageDataList: imageDataList, date: date)
        let insertIndex = logs.insertionIndex(of: newLog) { $0.date > $1.date }
        logs.insert(newLog, at: insertIndex)
        insertIntoDayIndex(newLog)
        generateAIToast(for: type, detail: detail)
    }
    
    func updateLog(id: UUID, detail: String, note: String, duration: Int, imageDataList: [Data], date: Date) {
        if let index = logs.firstIndex(where: { $0.id == id }) {
            let oldLog = logs[index]
            let updatedLog = LogItem(id: id, type: oldLog.type, detail: detail, note: note, duration: duration, imageDataList: imageDataList, date: date)
            logs.remove(at: index)
            removeFromDayIndex(oldLog)
            let insertIndex = logs.insertionIndex(of: updatedLog) { $0.date > $1.date }
            logs.insert(updatedLog, at: insertIndex)
            insertIntoDayIndex(updatedLog)
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
    
    private func prefillDummyData() {
        let past = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        addLog(type: .water, detail: "500ml", note: "起床第一杯", duration: 0, imageDataList: [], date: past)
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
    @StateObject var viewModel = AppViewModel()
    @State private var showDashboard = false; @State private var showCalendar = false; @State private var activeSheet: SheetContext? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                GridBackground()
                VStack(spacing: 30) {
                    VStack(spacing: 5) {
                        Text("VIBE CHECK").font(.system(size: 34, weight: .black, design: .rounded))
                        Text("Log your daily inputs & outputs.").font(.system(size: 17, weight: .semibold)).foregroundColor(AppTheme.black.opacity(0.6))
                    }.padding(.top, 50)
                    Spacer()
                    LazyVGrid(columns: LayoutMetrics.homeGridColumns, spacing: 20) {
                        ForEach(LogType.allCases, id: \.self) { type in
                            Button(action: { activeSheet = .new(type, Date()) }) {
                                VStack(alignment: .leading) {
                                    HStack { Spacer(); Text(type.icon).font(.system(size: 40)) }
                                    Spacer()
                                    Text(type.title).font(.system(size: 20, weight: .bold, design: .rounded)).foregroundColor(type == .poop ? .black : .white)
                                }.padding(20).aspectRatio(1, contentMode: .fill).modernStyle(color: type.color, radius: 32)
                            }.buttonStyle(ScaleButtonStyle())
                        }
                    }.padding(.horizontal, 24)
                    Spacer()
                    HStack(spacing: 15) {
                        Button(action: { showDashboard = true }) { Text("Dashboard").font(.system(size: 17, weight: .bold)).foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, 18).modernStyle(color: AppTheme.black, radius: 100) }
                        Button(action: { showCalendar = true }) { Text("Calendar").font(.system(size: 17, weight: .bold)).foregroundColor(.black).frame(maxWidth: .infinity).padding(.vertical, 18).modernStyle(color: AppTheme.lightGray, radius: 100) }
                    }.padding(.horizontal, 24).padding(.bottom, 40)
                }
            }
            .navigationDestination(isPresented: $showDashboard) { DashboardView() }
            .navigationDestination(isPresented: $showCalendar) { VibeCalendarView() }
            .sheet(item: $activeSheet) { context in
                InputSheetRouter(context: context)
                    .presentationDetents([.height(context.sheetHeight)])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(28)
                    .presentationBackground(.white)
            }
        }.environmentObject(viewModel)
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
            return 620
        case .food:
            return 720
        case .poop:
            return 760
        }
    }
}

// MARK: - 4. 超紧凑输入面板集合
struct BaseInputSheet<Content: View>: View {
    var title: String; var isEditMode: Bool; var btnColor: Color
    @Binding var note: String; @Binding var logTime: Date; @Binding var duration: Int; @Binding var imageDataList: [Data]
    var showDuration: Bool = false; var showPhotoPicker: Bool = true; var action: () -> Void; var content: Content
    @Environment(\.dismiss) var dismiss
    
    @State private var showActionSheet = false; @State private var showImagePicker = false; @State private var imageSourceType: UIImagePickerController.SourceType = .photoLibrary
    private let previewSize: CGFloat = 50
    
    init(title: String, isEditMode: Bool, btnColor: Color, note: Binding<String>, logTime: Binding<Date>, duration: Binding<Int>, imageDataList: Binding<[Data]>, showDuration: Bool = false, showPhotoPicker: Bool = true, action: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.title = title; self.isEditMode = isEditMode; self.btnColor = btnColor; self._note = note; self._logTime = logTime; self._duration = duration; self._imageDataList = imageDataList; self.showDuration = showDuration; self.showPhotoPicker = showPhotoPicker; self.action = action; self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.system(size: 26, weight: .black, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .padding(.top, 40)

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
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 18)
        .frame(maxWidth: .infinity, alignment: .top)
        .background(Color.white)
        .confirmationDialog("Photo Source", isPresented: $showActionSheet, titleVisibility: .hidden) { Button("Take Photo") { imageSourceType = .camera; showImagePicker = true }; Button("Photo Library") { imageSourceType = .photoLibrary; showImagePicker = true }; Button("Cancel", role: .cancel) {} }
        .sheet(isPresented: $showImagePicker) { ImagePickerView(selectedImages: $imageDataList, sourceType: imageSourceType).ignoresSafeArea() }
    }

    private var metadataPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
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
        }) {
            VStack(spacing: 16) {
                LazyVGrid(columns: LayoutMetrics.waterGridColumns, spacing: 10) {
                    ForEach(DataSets.waterOptions, id: \.self) { val in Button(action: { ml = val }) { Text("\(val)ml").font(.system(size: 14, weight: .bold)).foregroundColor(ml == val ? .white : .black).frame(maxWidth: .infinity).frame(height: 40).modernStyle(color: ml == val ? AppTheme.water : AppTheme.lightGray, radius: 100) } }
                }
                HStack {
                    Text("\(formattedML) ml")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .frame(width: 110, alignment: .leading)
                    Slider(value: Binding(get: { Double(ml) }, set: { ml = Int($0) }), in: 0...1500, step: 50).tint(AppTheme.water)
                }.padding(.horizontal, 10).padding(.vertical, 10).background(AppTheme.lightGray).cornerRadius(16)
            }
        }.onAppear(perform: initializeIfNeeded)
    }

    private func initializeIfNeeded() {
        guard !didInitialize else { return }
        didInitialize = true
        time = initialDate
        if let log = editLog {
            ml = Int(log.detail.replacingOccurrences(of: "ml", with: "")) ?? 300
            note = log.note
            photoDataList = log.imageDataList
        }
    }
}

// 4.2 饮料 (紧凑胶囊版)
struct DrinkInputSheet: View {
    @EnvironmentObject var viewModel: AppViewModel; var editLog: LogItem?; var initialDate: Date
    @State private var selected: String = "Coffee"; @State private var note: String = ""; @State private var time: Date = Date(); @State private var dur: Int = 0; @State private var photoDataList: [Data] = []
    @State private var didInitialize = false
    var body: some View {
        BaseInputSheet(title: "CHOOSE POISON", isEditMode: editLog != nil, btnColor: Color(hex: "1C1C1E"), note: $note, logTime: $time, duration: $dur, imageDataList: $photoDataList, action: {
            if let log = editLog { viewModel.updateLog(id: log.id, detail: selected, note: note, duration: dur, imageDataList: photoDataList, date: time) }
            else { viewModel.addLog(type: .drink, detail: selected, note: note, duration: dur, imageDataList: photoDataList, date: time) }
        }) {
            LazyVGrid(columns: LayoutMetrics.pairGridColumns, spacing: 10) {
                ForEach(DataSets.drinks, id: \.0) { drink in Button(action: { selected = drink.0 }) { HStack { Text(drink.1).font(.system(size: 20)); Text(drink.0).font(.system(size: 15, weight: .bold)).foregroundColor(selected == drink.0 ? .white : .black) }.frame(maxWidth: .infinity).frame(height: 50).modernStyle(color: selected == drink.0 ? AppTheme.drink : AppTheme.lightGray, radius: 16) }.buttonStyle(ScaleButtonStyle()) }
            }
        }.onAppear(perform: initializeIfNeeded)
    }

    private func initializeIfNeeded() {
        guard !didInitialize else { return }
        didInitialize = true
        time = initialDate
        if let log = editLog {
            selected = log.detail
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
            selected = log.detail
            note = log.note
            dur = log.duration
            photoDataList = log.imageDataList
        }
    }
}

// 4.4 排泄 (紧凑方块版)
struct PoopInputSheet: View {
    @EnvironmentObject var viewModel: AppViewModel; var editLog: LogItem?; var initialDate: Date
    @State private var selectedShapeID: String = "poop_4"; @State private var selectedColorID: String = PoopOptionResolver.defaultColorID; @State private var note: String = ""; @State private var time: Date = Date(); @State private var dur: Int = 5; @State private var photoDataList: [Data] = []
    @State private var didInitialize = false
    var body: some View {
        BaseInputSheet(title: "CAPTAIN'S LOG", isEditMode: editLog != nil, btnColor: Color(hex: "1C1C1E"), note: $note, logTime: $time, duration: $dur, imageDataList: $photoDataList, showDuration: true, showPhotoPicker: false, action: {
            let detailValue = PoopRecordValue(shapeID: selectedShapeID, colorID: selectedColorID).detailValue
            if let log = editLog { viewModel.updateLog(id: log.id, detail: detailValue, note: note, duration: dur, imageDataList: photoDataList, date: time) }
            else { viewModel.addLog(type: .poop, detail: detailValue, note: note, duration: dur, imageDataList: photoDataList, date: time) }
        }) {
            VStack(alignment: .leading, spacing: 14) {
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
                            .modernStyle(color: selectedShapeID == poop.id ? AppTheme.poop : AppTheme.lightGray, radius: 16)
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("COLOR")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.gray)
                    LazyVGrid(columns: LayoutMetrics.poopGridColumns, spacing: 10) {
                        ForEach(DataSets.poopColors, id: \.id) { poopColor in
                            Button(action: { selectedColorID = poopColor.id }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(selectedColorID == poopColor.id ? AppTheme.poop.opacity(0.24) : AppTheme.lightGray)
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
            }
        }.onAppear(perform: initializeIfNeeded)
    }

    private func initializeIfNeeded() {
        guard !didInitialize else { return }
        didInitialize = true
        time = initialDate
        if let log = editLog {
            let recordValue = PoopRecordValue(detail: log.detail)
            selectedShapeID = recordValue.shapeID
            selectedColorID = recordValue.colorID
            note = log.note
            dur = log.duration
            photoDataList = log.imageDataList
        }
    }
}

// MARK: - 5. Dashboard 与 列表组件 保持原样 (节约篇幅)
struct DashboardView: View {
    @EnvironmentObject var viewModel: AppViewModel; @Environment(\.dismiss) var dismiss; @State private var activeSheet: SheetContext? = nil
    var body: some View {
        let todayLogs = viewModel.logs(for: Date())
        ZStack {
            Color.white.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    HStack { Button(action: { dismiss() }) { Image(systemName: "arrow.left").font(.system(size: 20, weight: .bold)).foregroundColor(.black).padding(14).background(AppTheme.lightGray).clipShape(Circle()) }; Spacer() }.padding(.top, 10).padding(.horizontal, 24)
                    VStack(alignment: .leading, spacing: 5) { Text("TODAY!").font(.system(size: 34, weight: .black, design: .rounded)); Text("今天过得像个人样吗？").font(.system(size: 17, weight: .semibold)).foregroundColor(.gray) }.padding(.horizontal, 24)
                    Text("TODAY'S LOGS").font(.system(size: 20, weight: .bold, design: .rounded)).padding(.top, 10).padding(.horizontal, 24)
                    if todayLogs.isEmpty { Text("No logs today.").foregroundColor(.gray).padding(.horizontal, 24) }
                    else { LazyVStack(spacing: 16) { ForEach(todayLogs) { log in Button(action: { activeSheet = .edit(log) }) { LogRowView(log: log) }.buttonStyle(ScaleButtonStyle()) } }.padding(.horizontal, 24).padding(.bottom, 150) }
                }
            }
            VStack { Spacer(); HStack(alignment: .top) { Text(viewModel.aiJudgeText).font(.system(size: 17, weight: .medium)).foregroundColor(.black).padding(20) }.frame(maxWidth: .infinity, alignment: .leading).background(.ultraThinMaterial).cornerRadius(24).shadow(color: Color.black.opacity(0.08), radius: 20, y: 10).padding(.horizontal, 24).padding(.bottom, 40) }.ignoresSafeArea(.keyboard)
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
        let poopRecord = log.type == .poop ? PoopRecordValue(detail: log.detail) : nil
        self.poopImage = poopRecord.flatMap { record in
            DataSets.poops.first(where: { $0.id == record.shapeID }).flatMap { PoopAssetLoader.image(named: $0.imageName) }
        }
        self.poopColor = poopRecord?.colorOption
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(log.type.icon).font(.system(size: 24)).padding(12).background(Color.white.opacity(0.3)).clipShape(Circle())
                VStack(alignment: .leading) { Text(log.type.title).font(.system(size: 17, weight: .bold)).foregroundColor(log.type == .poop ? .black : .white); Text(timeText).font(.system(size: 12, weight: .medium)).foregroundColor(log.type == .poop ? .black.opacity(0.6) : .white.opacity(0.8)) }
                Spacer()
                VStack(alignment: .trailing) {
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
                        Text(log.detail).font(.system(size: 14, weight: .bold)).padding(.horizontal, 15).padding(.vertical, 8).background(Color.white).foregroundColor(.black).cornerRadius(100)
                    }
                    if log.duration > 0 { Text("\(log.duration) mins").font(.system(size: 12, weight: .medium)).foregroundColor(log.type == .poop ? .black.opacity(0.6) : .white.opacity(0.8)) }
                }
            }
            if let image { Image(uiImage: image).resizable().scaledToFill().frame(height: 150).frame(maxWidth: .infinity).clipShape(RoundedRectangle(cornerRadius: 16)).padding(.top, 5) }
            if !log.note.isEmpty { Text("Note: \(log.note)").font(.system(size: 14, weight: .medium)).foregroundColor(log.type == .poop ? .black.opacity(0.8) : .white.opacity(0.9)).padding(.top, 5) }
        }.padding(16).modernStyle(color: log.type.color, radius: 28)
    }
}

// MARK: - 6. 日历看板
struct VibeCalendarView: View {
    @EnvironmentObject var viewModel: AppViewModel; @Environment(\.dismiss) var dismiss; @State private var currentDate = Date(); @State private var selectedDate = Calendar.current.startOfDay(for: Date()); @State private var activeSheet: SheetContext? = nil
    let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    private let calendar = Calendar.current
    var body: some View {
        let days = viewModel.generateCalendarGrid(for: currentDate)
        let monthDays = days.compactMap { $0 }
        ZStack {
            Color.white.ignoresSafeArea()
            VStack(spacing: 20) {
                HStack { Button(action: { dismiss() }) { Image(systemName: "arrow.left").font(.system(size: 20, weight: .bold)).foregroundColor(.black).padding(14).background(AppTheme.lightGray).clipShape(Circle()) }; Spacer(); HStack(spacing: 20) { Button(action: { changeMonth(by: -1) }) { Image(systemName: "chevron.left").font(.title3.bold()).foregroundColor(.black) }; Text(monthYearString(from: currentDate)).font(.system(size: 20, weight: .black, design: .rounded)).frame(width: 120); Button(action: { changeMonth(by: 1) }) { Image(systemName: "chevron.right").font(.title3.bold()).foregroundColor(.black) } } }.padding(.horizontal, 24).padding(.top, 10)
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

struct CalendarRecordsPager: View {
    let days: [Date]
    @Binding var selectedDate: Date
    let onAddLog: (LogType) -> Void
    let onEditLog: (LogItem) -> Void
    @EnvironmentObject var viewModel: AppViewModel

    var body: some View {
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
                Text("\(viewModel.logCount(for: selectedDate))")
                    .font(.system(size: 17, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .frame(width: 34, height: 34)
                    .background(AppTheme.black)
                    .clipShape(Circle())
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
                VStack(spacing: 8) {
                    Spacer(minLength: 0)
                    Text("No records this day.")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.gray.opacity(0.55))
                    Text("Swipe left or right to browse another date.")
                        .font(.system(size: 13, weight: .semibold))
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
        let poopRecord = log.type == .poop ? PoopRecordValue(detail: log.detail) : nil
        self.poopImage = poopRecord.flatMap { record in
            DataSets.poops.first(where: { $0.id == record.shapeID }).flatMap { PoopAssetLoader.image(named: $0.imageName) }
        }
        self.poopColor = poopRecord?.colorOption
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(log.type.icon)
                        .font(.system(size: 22))
                    Spacer()
                    Text(timeText)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.gray)
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
                    Text(log.detail)
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundColor(AppTheme.black)
                        .lineLimit(2)
                        .minimumScaleFactor(0.72)
                }

                if log.duration > 0 {
                    Text("\(log.duration) min")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.gray)
                }

                if !log.note.isEmpty {
                    Text(log.note)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, minHeight: 118, alignment: .topLeading)
            .padding(14)
            .background(log.type.color.opacity(log.type == .poop ? 0.32 : 0.16))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 46, height: 46)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .padding(10)
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
