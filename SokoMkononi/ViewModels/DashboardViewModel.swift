import SwiftUI
import Combine
import SwiftData

// MARK: - Load State

enum LoadState<T> {
    case idle
    case loading
    case success(T)
    case failure(AppError)
    
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
    
    var data: T? {
        if case .success(let d) = self { return d }
        return nil
    }
    
    var error: AppError? {
        if case .failure(let e) = self { return e }
        return nil
    }
}

// MARK: - Dashboard ViewModel

@MainActor
final class DashboardViewModel: ObservableObject {
    
    // MARK: - Published State
    @Published private(set) var loadState: LoadState<[CropDTO]> = .idle
    @Published var searchText: String = ""
    @Published var selectedRegion: Region = .all
    @Published var selectedCategory: CropCategory = .all
    @Published var sortOption: SortOption = .nameAscending
    @Published private(set) var lastUpdated: Date?
    @Published private(set) var isOfflineMode: Bool = false
    
    // MARK: - Computed Properties
    
    var filteredCrops: [CropDTO] {
        guard case .success(let crops) = loadState else { return [] }
        
        var result = crops
        
        // Search filter
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.category.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Region filter
        if selectedRegion != .all {
            result = result.filter { $0.region == selectedRegion.rawValue }
        }
        
        // Category filter
        if selectedCategory != .all {
            result = result.filter { $0.category == selectedCategory.rawValue }
        }
        
        // Sort
        return sortOption.sort(result)
    }
    
    var hasResults: Bool { !filteredCrops.isEmpty }
    
    // MARK: - Dependencies
    
    private let networkService: CropDataServiceProtocol
    private let cacheService: CropCacheService
    private var refreshTask: Task<Void, Never>?
    
    // MARK: - Init
    
    init(networkService: CropDataServiceProtocol = CropNetworkService.shared,
         cacheService: CropCacheService) {
        self.networkService = networkService
        self.cacheService = cacheService
    }
    
    // MARK: - Actions
    
    func loadCrops(forceRefresh: Bool = false) {
        guard loadState.isLoading == false || forceRefresh else { return }
        
        refreshTask?.cancel()
        refreshTask = Task {
            await performLoad()
        }
    }
    
    func refresh() async {
        await performLoad(forceNetwork: true)
    }
    
    func resetFilters() {
        searchText = ""
        selectedRegion = .all
        selectedCategory = .all
        sortOption = .nameAscending
    }
    
    // MARK: - Private
    
    private func performLoad(forceNetwork: Bool = false) async {
        loadState = .loading
        
        do {
            // Try cache first for instant display
            let cached = try cacheService.loadCachedCrops()
            if !cached.isEmpty && !forceNetwork {
                loadState = .success(cached)
                lastUpdated = try cacheService.lastUpdated()
                isOfflineMode = !NetworkMonitor.shared.isConnected
                return
            }
            
            // Fetch fresh data
            let crops = try await networkService.fetchCrops()
            
            // Cache results
            try cacheService.cacheCrops(crops)
            
            loadState = .success(crops)
            lastUpdated = Date()
            isOfflineMode = false
            
        } catch let appError as AppError {
            // Try cache fallback on network error
            if let cached = try? cacheService.loadCachedCrops(), !cached.isEmpty {
                loadState = .success(cached)
                lastUpdated = try? cacheService.lastUpdated()
                isOfflineMode = true
            } else {
                loadState = .failure(appError)
            }
        } catch {
            loadState = .failure(.unknown(error))
        }
    }
}

// MARK: - Sort Options

enum SortOption: String, CaseIterable {
    case nameAscending = "Jina A-Z"
    case nameDescending = "Jina Z-A"
    case priceHighest = "Bei Juu"
    case priceLowest = "Bei Chini"
    case trending = "Inapanda"
    
    func sort(_ crops: [CropDTO]) -> [CropDTO] {
        switch self {
        case .nameAscending: return crops.sorted { $0.name < $1.name }
        case .nameDescending: return crops.sorted { $0.name > $1.name }
        case .priceHighest: return crops.sorted { $0.currentPrice > $1.currentPrice }
        case .priceLowest: return crops.sorted { $0.currentPrice < $1.currentPrice }
        case .trending: return crops.sorted { $0.trend == "up" && $1.trend != "up" }
        }
    }
}
