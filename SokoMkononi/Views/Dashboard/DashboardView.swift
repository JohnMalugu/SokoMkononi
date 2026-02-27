import SwiftUI
import SwiftData

struct DashboardView: View {
    
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var router: AppRouter
    @StateObject private var viewModel: DashboardViewModel
    
    init() {
        // ViewModel is created lazily; modelContext injected via onAppear
        _viewModel = StateObject(wrappedValue: DashboardViewModel(
            cacheService: CropCacheService(modelContext: ModelContext(try! ModelContainer(for: CropModel.self, PriceHistoryModel.self)))
        ))
    }
    
    var body: some View {
        NavigationStack(path: $router.dashboardPath) {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    offlineBanner
                    filterBar
                    contentArea
                }
            }
            .navigationTitle("🌾 Soko Mkononi")
            .navigationBarTitleDisplayMode(.large)
            .toolbar { toolbarContent }
            .searchable(
                text: $viewModel.searchText,
                prompt: "Tafuta zao..."
            )
            .navigationDestination(for: CropDTO.self) { crop in
                PriceDetailView(crop: crop)
            }
            .refreshable {
                await viewModel.refresh()
            }
            .onAppear {
                viewModel.loadCrops()
            }
            .alert("Hitilafu", isPresented: $router.showingError) {
                Button("Sawa") { }
            } message: {
                Text(router.errorMessage)
            }
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var offlineBanner: some View {
        if viewModel.isOfflineMode {
            OfflineBannerView(lastUpdated: viewModel.lastUpdated)
        }
    }
    
    @ViewBuilder
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                RegionPickerChip(selected: $viewModel.selectedRegion)
                CategoryPickerChip(selected: $viewModel.selectedCategory)
                SortChip(selected: $viewModel.sortOption)
                
                if viewModel.selectedRegion != .all ||
                   viewModel.selectedCategory != .all ||
                   viewModel.sortOption != .nameAscending {
                    Button("Futa") {
                        withAnimation { viewModel.resetFilters() }
                    }
                    .font(.caption)
                    .foregroundStyle(AppTheme.primary)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
    
    @ViewBuilder
    private var contentArea: some View {
        switch viewModel.loadState {
        case .idle:
            EmptyView()
            
        case .loading:
            LoadingView(message: "Inapakia bei za mazao...")
            
        case .success:
            if viewModel.hasResults {
                cropList
            } else {
                EmptyStateView(
                    icon: "magnifyingglass",
                    title: "Hakuna mazao",
                    subtitle: "Jaribu maudhui tofauti ya utafutaji"
                )
            }
            
        case .failure(let error):
            ErrorStateView(error: error) {
                viewModel.loadCrops(forceRefresh: true)
            }
        }
    }
    
    private var cropList: some View {
        List(viewModel.filteredCrops) { crop in
            Button {
                router.dashboardPath.append(crop)
            } label: {
                CropRowView(crop: crop)
            }
            .buttonStyle(.plain)
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .animation(.easeInOut(duration: 0.3), value: viewModel.filteredCrops.map(\.id))
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            HStack(spacing: 12) {
                NetworkStatusIcon()
                if let date = viewModel.lastUpdated {
                    Text(date, style: .relative)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
