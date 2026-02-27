import SwiftUI
import SwiftData
import Combine


// MARK: - Price Detail ViewModel

@MainActor
final class PriceDetailViewModel: ObservableObject {
    
    @Published private(set) var crop: CropDTO
    @Published private(set) var isSaved: Bool = false
    @Published var selectedTimeRange: TimeRange = .week
    @Published private(set) var marketComparison: [MarketPrice] = []
    @Published private(set) var priceStats: PriceStats?
    
    private let cacheService: CropCacheService
    
    init(crop: CropDTO, cacheService: CropCacheService) {
        self.crop = crop
        self.cacheService = cacheService
        self.computeStats()
        self.loadSavedState()
    }
    
    // MARK: - Computed
    
    var filteredHistory: [PriceHistoryDTO] {
        let days = selectedTimeRange.days
        let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return crop.history.filter { entry in
            guard let date = entry.parsedDate else { return false }
            return date >= cutoff
        }
    }
    
    var chartTitle: String {
        "Bei kwa \(selectedTimeRange.label)"
    }
    
    // MARK: - Actions
    
    func toggleWatchlist() {
        do {
            isSaved = try cacheService.toggleSave(cropId: crop.id)
        } catch {
            print("Error toggling watchlist: \(error)")
        }
    }
    
    func selectTimeRange(_ range: TimeRange) {
        selectedTimeRange = range
    }
    
    // MARK: - Private
    
    private func loadSavedState() {
        isSaved = (try? cacheService.isSaved(cropId: crop.id)) ?? false
    }
    
    private func computeStats() {
        let prices = crop.history.map { $0.price }
        guard !prices.isEmpty else { return }
        
        priceStats = PriceStats(
            min: prices.min() ?? 0,
            max: prices.max() ?? 0,
            average: prices.reduce(0, +) / Double(prices.count),
            current: crop.currentPrice
        )
        
        // Mock market comparison across regions
        marketComparison = Region.allCases
            .filter { $0 != .all }
            .map { region in
                let variation = Double.random(in: 0.85...1.15)
                return MarketPrice(
                    region: region.rawValue,
                    price: crop.currentPrice * variation
                )
            }
            .sorted { $0.price > $1.price }
    }
}

// MARK: - Supporting Types

enum TimeRange: String, CaseIterable {
    case week = "Wiki"
    case month = "Mwezi"
    case threeMonths = "Miezi 3"
    
    var days: Int {
        switch self {
        case .week: return 7
        case .month: return 30
        case .threeMonths: return 90
        }
    }
    
    var label: String { rawValue }
}

struct PriceStats {
    let min: Double
    let max: Double
    let average: Double
    let current: Double
    
    var percentageFromAverage: Double {
        ((current - average) / average) * 100
    }
    
    var isAboveAverage: Bool { current > average }
}

struct MarketPrice: Identifiable {
    var id: String { region }
    let region: String
    let price: Double
}
