import SwiftUI
import SwiftData

@main
struct SokoMkononiApp: App {
    
    // MARK: - SwiftData Container
    let modelContainer: ModelContainer = {
        let schema = Schema([CropModel.self, PriceHistoryModel.self, AppSettingsModel.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Failed to create ModelContainer: \(error.localizedDescription)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .modelContainer(modelContainer)
        }
    }
}
