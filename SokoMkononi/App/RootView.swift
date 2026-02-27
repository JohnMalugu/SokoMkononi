import SwiftUI

struct RootView: View {
    @State private var selectedTab: AppTab = .dashboard
    @StateObject private var appRouter = AppRouter()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Soko", systemImage: "cart.fill")
                }
                .tag(AppTab.dashboard)
            
            WatchlistView()
                .tabItem {
                    Label("Kibindoni", systemImage: "bookmark.fill")
                }
                .tag(AppTab.watchlist)
            
            SettingsView()
                .tabItem {
                    Label("Mipangilio", systemImage: "gearshape.fill")
                }
                .tag(AppTab.settings)
        }
        .tint(AppTheme.primary)
        .environmentObject(appRouter)
    }
}

enum AppTab: Hashable {
    case dashboard, watchlist, settings
}
