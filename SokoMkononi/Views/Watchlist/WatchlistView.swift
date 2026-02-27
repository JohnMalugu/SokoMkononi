import SwiftUI
import SwiftData

struct WatchlistView: View {
    
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var router: AppRouter
    @StateObject private var viewModel: WatchlistViewModel
    
    init() {
        _viewModel = StateObject(wrappedValue: WatchlistViewModel(
            cacheService: CropCacheService(modelContext: ModelContext(try! ModelContainer(for: CropModel.self, PriceHistoryModel.self)))
        ))
    }
    
    var body: some View {
        NavigationStack(path: $router.watchlistPath) {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                if viewModel.savedCrops.isEmpty {
                    emptyState
                } else {
                    savedList
                }
            }
            .navigationTitle("📌 Kibindoni")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    lastUpdatedLabel
                }
            }
            .navigationDestination(for: CropDTO.self) { crop in
                PriceDetailView(crop: crop)
            }
            .onAppear {
                viewModel.loadSavedCrops()
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "bookmark.slash")
                .font(.system(size: 64))
                .foregroundStyle(AppTheme.primary.opacity(0.4))
            
            VStack(spacing: 8) {
                Text("Hakuna Mazao Yaliyohifadhiwa")
                    .font(.title3.bold())
                
                Text("Bonyeza alama ya alamisho katika ukurasa wa zao kuongeza kwenye Kibindoni chako.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            OfflineSupportBadge()
        }
    }
    
    // MARK: - Saved List
    
    private var savedList: some View {
        List {
            Section {
                offlineSupportCard
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }
            
            Section("Mazao Yaliyohifadhiwa (\(viewModel.savedCrops.count))") {
                ForEach(viewModel.savedCrops) { crop in
                    Button {
                        router.watchlistPath.append(crop)
                    } label: {
                        CropRowView(crop: crop)
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            withAnimation {
                                viewModel.removeCrop(id: crop.id)
                            }
                        } label: {
                            Label("Ondoa", systemImage: "bookmark.slash")
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
    }
    
    // MARK: - Offline Support Card
    
    private var offlineSupportCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "wifi.slash")
                .font(.title2)
                .foregroundStyle(AppTheme.primary)
                .frame(width: 44, height: 44)
                .background(AppTheme.primary.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 3) {
                Text("Inafanya kazi bila mtandao")
                    .font(.subheadline.weight(.semibold))
                Text("Data imehifadhiwa kwenye simu yako")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let updated = viewModel.lastUpdated {
                    Text("Ilisasishwa: \(updated, style: .relative)")
                        .font(.caption2)
                        .foregroundStyle(AppTheme.primary)
                }
            }
            
            Spacer()
        }
        .padding(12)
        .background(AppTheme.primary.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var lastUpdatedLabel: some View {
        if let date = viewModel.lastUpdated {
            Text(date, style: .relative)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

struct OfflineSupportBadge: View {
    var body: some View {
        Label("Inafanya kazi bila mtandao", systemImage: "wifi.slash")
            .font(.caption)
            .foregroundStyle(AppTheme.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(AppTheme.primary.opacity(0.1))
            .clipShape(Capsule())
    }
}

#Preview {
    WatchlistView()
}
