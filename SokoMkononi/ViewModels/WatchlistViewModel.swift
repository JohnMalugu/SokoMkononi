import SwiftUI
import SwiftData
import Combine

@MainActor
final class WatchlistViewModel: ObservableObject {
    
    @Published private(set) var savedCrops: [CropDTO] = []
    @Published private(set) var lastUpdated: Date?
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let cacheService: CropCacheService
    
    init(cacheService: CropCacheService) {
        self.cacheService = cacheService
    }
    
    func loadSavedCrops() {
        do {
            savedCrops = try cacheService.savedCrops()
            lastUpdated = try cacheService.lastUpdated()
        } catch {
            errorMessage = "Imeshindwa kupakia: \(error.localizedDescription)"
        }
    }
    
    func removeCrop(id: String) {
        do {
            _ = try cacheService.toggleSave(cropId: id)
            savedCrops.removeAll { $0.id == id }
        } catch {
            errorMessage = "Imeshindwa kuondoa zao"
        }
    }
    
    var lastUpdatedLabel: String {
        guard let date = lastUpdated else { return "Haijulikani" }
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "sw")
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
