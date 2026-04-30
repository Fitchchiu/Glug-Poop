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
    static let cache = NSCache<NSData, UIImage>()

    static func image(from data: Data) -> UIImage? {
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

// MARK: - 1. 数据模型与状态管理
struct LogItem: Identifiable {
    let id: UUID
    let type: LogType
    let detail: String
    let note: String
    let duration: Int
    let imageData: Data?
    let date: Date
    
    init(id: UUID = UUID(), type: LogType, detail: String, note: String, duration: Int, imageData: Data?, date: Date) {
        self.id = id; self.type = type; self.detail = detail; self.note = note; self.duration = duration; self.imageData = imageData; self.date = date
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
        case .level1: return Color(hex: "FF2D55").opacity(0.8)
        case .level2: return Color(hex: "FFCC00").opacity(0.8)
        case .level3: return Color(hex: "AF52DE").opacity(0.6)
        case .level4: return Color(hex: "34C759").opacity(0.8)
        case .level5: return Color(hex: "007AFF").opacity(0.8)
        }
    }
}

class AppViewModel: ObservableObject {
    @Published var logs: [LogItem] = []
    @Published var vibeScore: Int = 70
    @Published var aiJudgeText: String = "\"今天表现平平，像个没有感情的产屎机器。🙄\""
    private let calendar = Calendar.current
    private var logsByDay: [Date: [LogItem]] = [:]

    init() { prefillDummyData() }
    
    func addLog(type: LogType, detail: String, note: String, duration: Int, imageData: Data?, date: Date) {
        let newLog = LogItem(type: type, detail: detail, note: note, duration: duration, imageData: imageData, date: date)
        let insertIndex = logs.insertionIndex(of: newLog) { $0.date > $1.date }
        logs.insert(newLog, at: insertIndex)
        insertIntoDayIndex(newLog)
        generateAIToast(for: type, detail: detail)
    }
    
    func updateLog(id: UUID, detail: String, note: String, duration: Int, imageData: Data?, date: Date) {
        if let index = logs.firstIndex(where: { $0.id == id }) {
            let oldLog = logs[index]
            let updatedLog = LogItem(id: id, type: oldLog.type, detail: detail, note: note, duration: duration, imageData: imageData, date: date)
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
        var days: [Date?] = []
        let components = calendar.dateComponents([.year, .month], from: date)
        guard let firstDay = calendar.date(from: components) else { return [] }
        let firstWeekday = calendar.component(.weekday, from: firstDay) - 1
        for _ in 0..<firstWeekday { days.append(nil) }
        let daysInMonth = calendar.range(of: .day, in: .month, for: date)!.count
        for day in 1...daysInMonth { var dayComp = components; dayComp.day = day; days.append(calendar.date(from: dayComp)) }
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
        addLog(type: .water, detail: "500ml", note: "起床第一杯", duration: 0, imageData: nil, date: past)
    }
}

// MARK: - 2. 核心组件系统
struct ModernCardStyle: ViewModifier {
    var bgColor: Color; var cornerRadius: CGFloat = 32
    func body(content: Content) -> some View { content.background(bgColor).cornerRadius(cornerRadius).shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 10) }
}
extension View { func modernStyle(color: Color, radius: CGFloat = 32) -> some View { self.modifier(ModernCardStyle(bgColor: color, cornerRadius: radius)) } }

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View { configuration.label.scaleEffect(configuration.isPressed ? 0.95 : 1).animation(.spring(response: 0.4, dampingFraction: 0.6), value: configuration.isPressed) }
}

struct GridBackground: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let step: CGFloat = 30
                for x in stride(from: 0, through: geometry.size.width, by: step) { path.move(to: CGPoint(x: x, y: 0)); path.addLine(to: CGPoint(x: x, y: geometry.size.height)) }
                for y in stride(from: 0, through: geometry.size.height, by: step) { path.move(to: CGPoint(x: 0, y: y)); path.addLine(to: CGPoint(x: geometry.size.width, y: y)) }
            }.stroke(Color.gray.opacity(0.05), lineWidth: 1)
        }.ignoresSafeArea().background(Color.white)
    }
}

struct ImagePickerView: UIViewControllerRepresentable {
    @Binding var selectedImage: Data?; @Environment(\.presentationMode) private var presentationMode
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    func makeUIViewController(context: Context) -> UIImagePickerController { let picker = UIImagePickerController(); picker.delegate = context.coordinator; picker.sourceType = sourceType; picker.allowsEditing = true; return picker }
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePickerView; init(_ parent: ImagePickerView) { self.parent = parent }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage { parent.selectedImage = image.jpegData(compressionQuality: 0.6) }
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
    private let homeGridColumns = Array(repeating: GridItem(.flexible(), spacing: 20), count: 2)
    
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
                    LazyVGrid(columns: homeGridColumns, spacing: 20) {
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
                    .presentationSizing(.fitted)
                    .presentationCornerRadius(28)
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

// MARK: - 4. 超紧凑输入面板集合
struct BaseInputSheet<Content: View>: View {
    var title: String; var isEditMode: Bool; var btnColor: Color
    @Binding var note: String; @Binding var logTime: Date; @Binding var duration: Int; @Binding var imageData: Data?
    var showDuration: Bool = false; var showPhotoPicker: Bool = true; var action: () -> Void; var content: Content
    @Environment(\.dismiss) var dismiss
    
    @State private var showActionSheet = false; @State private var showImagePicker = false; @State private var imageSourceType: UIImagePickerController.SourceType = .photoLibrary
    
    init(title: String, isEditMode: Bool, btnColor: Color, note: Binding<String>, logTime: Binding<Date>, duration: Binding<Int>, imageData: Binding<Data?>, showDuration: Bool = false, showPhotoPicker: Bool = true, action: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.title = title; self.isEditMode = isEditMode; self.btnColor = btnColor; self._note = note; self._logTime = logTime; self._duration = duration; self._imageData = imageData; self.showDuration = showDuration; self.showPhotoPicker = showPhotoPicker; self.action = action; self.content = content()
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            // 彻底移除 ScrollView，采用紧凑 VStack
            VStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 3).fill(Color.gray.opacity(0.3)).frame(width: 40, height: 5).padding(.top, 8)
                Text(title).font(.system(size: 26, weight: .black, design: .rounded))
                
                content
                
                metadataPanel
                
                // 相机与备注并排 (空间魔法)
                HStack(spacing: 12) {
                    if showPhotoPicker {
                        if let data = imageData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage).resizable().scaledToFill().frame(width: 50, height: 50).clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(Button(action: { imageData = nil }) { Image(systemName: "xmark.circle.fill").foregroundColor(.white).background(Color.black.clipShape(Circle())) }.offset(x: 5, y: -5), alignment: .topTrailing)
                        } else {
                            Button(action: { showActionSheet = true }) {
                                Image(systemName: "camera.fill").font(.title2).foregroundColor(.gray).frame(width: 50, height: 50).background(Color(hex: "F2F2F7")).cornerRadius(12)
                            }
                        }
                    }
                    TextField("Note (Optional)", text: $note).padding(.horizontal, 15).frame(height: 50).background(Color(hex: "F2F2F7")).cornerRadius(12)
                }
                
                Button(action: { action(); dismiss() }) {
                    Text(isEditMode ? "UPDATE IT" : "LOG IT").font(.system(size: 17, weight: .bold)).foregroundColor(.white).frame(maxWidth: .infinity).frame(height: 56).modernStyle(color: btnColor, radius: 100)
                }.buttonStyle(ScaleButtonStyle()).padding(.bottom, 10)
            }.padding(.horizontal, 24)
            .confirmationDialog("Photo Source", isPresented: $showActionSheet, titleVisibility: .hidden) { Button("Take Photo") { imageSourceType = .camera; showImagePicker = true }; Button("Photo Library") { imageSourceType = .photoLibrary; showImagePicker = true }; Button("Cancel", role: .cancel) {} }
            .sheet(isPresented: $showImagePicker) { ImagePickerView(selectedImage: $imageData, sourceType: imageSourceType).ignoresSafeArea() }
        }
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
    @State private var ml: Int = 300; @State private var note: String = ""; @State private var time: Date = Date(); @State private var dur: Int = 0; @State private var photoData: Data? = nil
    let options = [100, 300, 500, 750, 1000]
    private let gridColumns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)
    private var formattedML: String {
        Formatters.wholeNumber.string(from: NSNumber(value: ml)) ?? "\(ml)"
    }
    var body: some View {
        BaseInputSheet(title: "HYDRATE!", isEditMode: editLog != nil, btnColor: Color(hex: "1C1C1E"), note: $note, logTime: $time, duration: $dur, imageData: $photoData, action: {
            if let log = editLog { viewModel.updateLog(id: log.id, detail: "\(ml)ml", note: note, duration: dur, imageData: photoData, date: time) }
            else { viewModel.addLog(type: .water, detail: "\(ml)ml", note: note, duration: dur, imageData: photoData, date: time) }
        }) {
            VStack(spacing: 16) {
                LazyVGrid(columns: gridColumns, spacing: 10) {
                    ForEach(options, id: \.self) { val in Button(action: { ml = val }) { Text("\(val)ml").font(.system(size: 14, weight: .bold)).foregroundColor(ml == val ? .white : .black).frame(maxWidth: .infinity).frame(height: 40).modernStyle(color: ml == val ? Color(hex: "007AFF") : Color(hex: "F2F2F7"), radius: 100) } }
                }
                HStack {
                    Text("\(formattedML) ml")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .frame(width: 110, alignment: .leading)
                    Slider(value: Binding(get: { Double(ml) }, set: { ml = Int($0) }), in: 0...1500, step: 50).accentColor(Color(hex: "007AFF"))
                }.padding(.horizontal, 10).padding(.vertical, 10).background(Color(hex: "F2F2F7")).cornerRadius(16)
            }
        }.onAppear { time = initialDate; if let log = editLog { ml = Int(log.detail.replacingOccurrences(of: "ml", with: "")) ?? 300; note = log.note; photoData = log.imageData } }
    }
}

// 4.2 饮料 (紧凑胶囊版)
struct DrinkInputSheet: View {
    @EnvironmentObject var viewModel: AppViewModel; var editLog: LogItem?; var initialDate: Date
    @State private var selected: String = "Coffee"; @State private var note: String = ""; @State private var time: Date = Date(); @State private var dur: Int = 0; @State private var photoData: Data? = nil
    let drinks = [("Coffee", "☕️", "9E7B62"), ("Boba", "🧋", "D4B59D"), ("Soda", "🥤", "FF5E3A"), ("Matcha", "🍵", "8EFA48"), ("Wine", "🍷", "800020"), ("Beer", "🍺", "F28E1C")]
    private let gridColumns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 2)
    var body: some View {
        BaseInputSheet(title: "CHOOSE POISON", isEditMode: editLog != nil, btnColor: Color(hex: "1C1C1E"), note: $note, logTime: $time, duration: $dur, imageData: $photoData, action: {
            if let log = editLog { viewModel.updateLog(id: log.id, detail: selected, note: note, duration: dur, imageData: photoData, date: time) }
            else { viewModel.addLog(type: .drink, detail: selected, note: note, duration: dur, imageData: photoData, date: time) }
        }) {
            LazyVGrid(columns: gridColumns, spacing: 10) {
                ForEach(drinks, id: \.0) { drink in Button(action: { selected = drink.0 }) { HStack { Text(drink.1).font(.system(size: 20)); Text(drink.0).font(.system(size: 15, weight: .bold)).foregroundColor(selected == drink.0 ? .white : .black) }.frame(maxWidth: .infinity).frame(height: 50).modernStyle(color: selected == drink.0 ? Color(hex: drink.2) : Color(hex: "F2F2F7"), radius: 16) }.buttonStyle(ScaleButtonStyle()) }
            }
        }.onAppear { time = initialDate; if let log = editLog { selected = log.detail; note = log.note; photoData = log.imageData } }
    }
}

// 4.3 食物 (紧凑胶囊版)
struct FoodInputSheet: View {
    @EnvironmentObject var viewModel: AppViewModel; var editLog: LogItem?; var initialDate: Date
    @State private var selected: String = "Burger🍔"; @State private var note: String = ""; @State private var time: Date = Date(); @State private var dur: Int = 15; @State private var photoData: Data? = nil
    let foods = [("Burger🍔", "FFCC00"), ("Salad🥗", "007AFF"), ("Pizza🍕", "FF2D55"), ("Sushi🍣", "34C759"), ("Tacos🌮", "FFCC00"), ("Ramen🍜", "007AFF"), ("Meat🥩", "FF2D55"), ("Sweet🍩", "AF52DE")]
    private let gridColumns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 2)
    var body: some View {
        BaseInputSheet(title: "FEED ME", isEditMode: editLog != nil, btnColor: Color(hex: "1C1C1E"), note: $note, logTime: $time, duration: $dur, imageData: $photoData, showDuration: true, action: {
            if let log = editLog { viewModel.updateLog(id: log.id, detail: selected, note: note, duration: dur, imageData: photoData, date: time) }
            else { viewModel.addLog(type: .food, detail: selected, note: note, duration: dur, imageData: photoData, date: time) }
        }) {
            LazyVGrid(columns: gridColumns, spacing: 10) {
                ForEach(foods, id: \.0) { food in Button(action: { selected = food.0 }) { Text(food.0).font(.system(size: 15, weight: .bold)).foregroundColor(selected == food.0 ? .white : .black).frame(maxWidth: .infinity).frame(height: 46).modernStyle(color: selected == food.0 ? Color(hex: food.1) : Color(hex: "F2F2F7"), radius: 100) }.buttonStyle(ScaleButtonStyle()) }
            }
        }.onAppear { time = initialDate; if let log = editLog { selected = log.detail; note = log.note; dur = log.duration; photoData = log.imageData } }
    }
}

// 4.4 排泄 (紧凑方块版)
struct PoopInputSheet: View {
    @EnvironmentObject var viewModel: AppViewModel; var editLog: LogItem?; var initialDate: Date
    @State private var selected: String = "😌"; @State private var note: String = ""; @State private var time: Date = Date(); @State private var dur: Int = 5; @State private var photoData: Data? = nil
    let poops = [("🤬", "FF5E3A"), ("😖", "FF9F0A"), ("😌", "FFCC00"), ("☺️", "34C759"), ("🫠", "64D2FF"), ("🤢", "30B0C7"), ("🌋", "8B0000"), ("💨", "A9A9A9")]
    private let gridColumns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 4)
    var body: some View {
        BaseInputSheet(title: "CAPTAIN'S LOG", isEditMode: editLog != nil, btnColor: Color(hex: "1C1C1E"), note: $note, logTime: $time, duration: $dur, imageData: $photoData, showDuration: true, showPhotoPicker: false, action: {
            if let log = editLog { viewModel.updateLog(id: log.id, detail: selected, note: note, duration: dur, imageData: photoData, date: time) }
            else { viewModel.addLog(type: .poop, detail: selected, note: note, duration: dur, imageData: photoData, date: time) }
        }) {
            LazyVGrid(columns: gridColumns, spacing: 10) {
                ForEach(poops, id: \.0) { poop in Button(action: { selected = poop.0 }) { Text(poop.0).font(.system(size: 28)).frame(maxWidth: .infinity).aspectRatio(1, contentMode: .fit).modernStyle(color: selected == poop.0 ? Color(hex: poop.1) : Color(hex: "F2F2F7"), radius: 16) }.buttonStyle(ScaleButtonStyle()) }
            }
        }.onAppear { time = initialDate; if let log = editLog { selected = log.detail; note = log.note; dur = log.duration; photoData = log.imageData } }
    }
}

// MARK: - 5. Dashboard 与 列表组件 保持原样 (节约篇幅)
struct DashboardView: View {
    @EnvironmentObject var viewModel: AppViewModel; @Environment(\.dismiss) var dismiss; @State private var activeSheet: SheetContext? = nil
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    HStack { Button(action: { dismiss() }) { Image(systemName: "arrow.left").font(.system(size: 20, weight: .bold)).foregroundColor(.black).padding(14).background(Color(hex: "F2F2F7")).clipShape(Circle()) }; Spacer() }.padding(.top, 10).padding(.horizontal, 24)
                    VStack(alignment: .leading, spacing: 5) { Text("TODAY!").font(.system(size: 34, weight: .black, design: .rounded)); Text("今天过得像个人样吗？").font(.system(size: 17, weight: .semibold)).foregroundColor(.gray) }.padding(.horizontal, 24)
                    Text("TODAY'S LOGS").font(.system(size: 20, weight: .bold, design: .rounded)).padding(.top, 10).padding(.horizontal, 24)
                    let todayLogs = viewModel.logs(for: Date())
                    if todayLogs.isEmpty { Text("No logs today.").foregroundColor(.gray).padding(.horizontal, 24) }
                    else { VStack(spacing: 16) { ForEach(todayLogs) { log in Button(action: { activeSheet = .edit(log) }) { LogRowView(log: log) }.buttonStyle(ScaleButtonStyle()) } }.padding(.horizontal, 24).padding(.bottom, 150) }
                }
            }
            VStack { Spacer(); HStack(alignment: .top) { Text(viewModel.aiJudgeText).font(.system(size: 17, weight: .medium)).foregroundColor(.black).padding(20) }.frame(maxWidth: .infinity, alignment: .leading).background(.ultraThinMaterial).cornerRadius(24).shadow(color: Color.black.opacity(0.08), radius: 20, y: 10).padding(.horizontal, 24).padding(.bottom, 40) }.ignoresSafeArea(.keyboard)
        }
        .navigationBarHidden(true)
        .sheet(item: $activeSheet) { context in
            InputSheetRouter(context: context)
                .presentationSizing(.fitted)
                .presentationCornerRadius(28)
        }
    }
}

struct LogRowView: View {
    let log: LogItem
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(log.type.icon).font(.system(size: 24)).padding(12).background(Color.white.opacity(0.3)).clipShape(Circle())
                VStack(alignment: .leading) { Text(log.type.title).font(.system(size: 17, weight: .bold)).foregroundColor(log.type == .poop ? .black : .white); Text(Formatters.logTime.string(from: log.date)).font(.system(size: 12, weight: .medium)).foregroundColor(log.type == .poop ? .black.opacity(0.6) : .white.opacity(0.8)) }
                Spacer()
                VStack(alignment: .trailing) { Text(log.detail).font(.system(size: 14, weight: .bold)).padding(.horizontal, 15).padding(.vertical, 8).background(Color.white).foregroundColor(.black).cornerRadius(100); if log.duration > 0 { Text("\(log.duration) mins").font(.system(size: 12, weight: .medium)).foregroundColor(log.type == .poop ? .black.opacity(0.6) : .white.opacity(0.8)) } }
            }
            if let data = log.imageData, let uiImage = ImageDecoder.image(from: data) { Image(uiImage: uiImage).resizable().scaledToFill().frame(height: 150).frame(maxWidth: .infinity).clipShape(RoundedRectangle(cornerRadius: 16)).padding(.top, 5) }
            if !log.note.isEmpty { Text("Note: \(log.note)").font(.system(size: 14, weight: .medium)).foregroundColor(log.type == .poop ? .black.opacity(0.8) : .white.opacity(0.9)).padding(.top, 5) }
        }.padding(16).modernStyle(color: log.type.color, radius: 28)
    }
}

// MARK: - 6. 日历看板
struct VibeCalendarView: View {
    @EnvironmentObject var viewModel: AppViewModel; @Environment(\.dismiss) var dismiss; @State private var currentDate = Date(); @State private var selectedDateForSheet: Date? = nil
    let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    private let calendarColumns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 7)
    var body: some View {
        let days = viewModel.generateCalendarGrid(for: currentDate)
        ZStack {
            Color.white.ignoresSafeArea()
            VStack(spacing: 20) {
                HStack { Button(action: { dismiss() }) { Image(systemName: "arrow.left").font(.system(size: 20, weight: .bold)).foregroundColor(.black).padding(14).background(Color(hex: "F2F2F7")).clipShape(Circle()) }; Spacer(); HStack(spacing: 20) { Button(action: { changeMonth(by: -1) }) { Image(systemName: "chevron.left").font(.title3.bold()).foregroundColor(.black) }; Text(monthYearString(from: currentDate)).font(.system(size: 20, weight: .black, design: .rounded)).frame(width: 120); Button(action: { changeMonth(by: 1) }) { Image(systemName: "chevron.right").font(.title3.bold()).foregroundColor(.black) } } }.padding(.horizontal, 24).padding(.top, 10)
                HStack { ForEach(daysOfWeek, id: \.self) { day in Text(day).font(.system(size: 12, weight: .bold)).foregroundColor(.gray).frame(maxWidth: .infinity) } }.padding(.horizontal, 16)
                LazyVGrid(columns: calendarColumns, spacing: 10) {
                    ForEach(days.indices, id: \.self) { index in
                        if let date = days[index] {
                            let vibe = viewModel.mockAIVibe(for: date)
                            Button(action: { selectedDateForSheet = date }) { ZStack { if let vibe = vibe { vibe.color } else { AppTheme.lightGray }; Text("\(Calendar.current.component(.day, from: date))").font(.system(size: 17, weight: .bold, design: .rounded)).foregroundColor(vibe != nil ? .white : .gray) }.cornerRadius(12).aspectRatio(1, contentMode: .fit) }.buttonStyle(ScaleButtonStyle())
                        } else { Color.clear.aspectRatio(1, contentMode: .fit) }
                    }
                }.padding(.horizontal, 16); Spacer()
            }
        }.navigationBarHidden(true).sheet(item: Binding( get: { selectedDateForSheet.map { DateWrapper(date: $0) } }, set: { selectedDateForSheet = $0?.date } )) { wrapper in DailyDetailSheet(date: wrapper.date).presentationDetents([.fraction(0.85)]) }
    }
    func changeMonth(by value: Int) { currentDate = Calendar.current.date(byAdding: .month, value: value, to: currentDate) ?? Date() }
    func monthYearString(from date: Date) -> String { Formatters.monthYear.string(from: date).uppercased() }
}
struct DateWrapper: Identifiable { let id = UUID(); let date: Date }

struct DailyDetailSheet: View {
    let date: Date; @EnvironmentObject var viewModel: AppViewModel; @State private var activeSheet: SheetContext? = nil
    var formattedDateString: String { Formatters.fullDate.string(from: date) }
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack(spacing: 20) {
                RoundedRectangle(cornerRadius: 3).fill(Color.gray.opacity(0.3)).frame(width: 40, height: 5).padding(.top, 10)
                Text(formattedDateString).font(.system(size: 28, weight: .black, design: .rounded))
                HStack(spacing: 15) { ForEach(LogType.allCases, id: \.self) { type in Button(action: { activeSheet = .new(type, date) }) { Text(type.icon).font(.system(size: 24)).frame(maxWidth: .infinity).padding(.vertical, 12).modernStyle(color: type.color.opacity(0.2), radius: 15) }.buttonStyle(ScaleButtonStyle()) } }.padding(.horizontal, 24)
                Text("RECORDS").font(.system(size: 14, weight: .bold)).foregroundColor(.gray).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 24)
                let dayLogs = viewModel.logs(for: date)
                if dayLogs.isEmpty { Spacer(); Text("Nothing logged this day.").font(.system(size: 17, weight: .semibold)).foregroundColor(.gray.opacity(0.5)); Spacer() }
                else { ScrollView { VStack(spacing: 16) { ForEach(dayLogs) { log in Button(action: { activeSheet = .edit(log) }) { LogRowView(log: log) }.buttonStyle(ScaleButtonStyle()) } }.padding(.horizontal, 24).padding(.bottom, 30) } }
            }
        }
        .sheet(item: $activeSheet) { context in
            InputSheetRouter(context: context)
                .presentationSizing(.fitted)
                .presentationCornerRadius(28)
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
