import SwiftUI
import Combine

/// Central navigation and routing manager
@MainActor
final class AppRouter: ObservableObject {
    @Published var dashboardPath = NavigationPath()
    @Published var watchlistPath = NavigationPath()
    @Published var selectedRegion: Region = .all
    @Published var showingError = false
    @Published var errorMessage: String = ""
    
    func navigateToCrop(_ crop: CropDTO) {
        dashboardPath.append(crop)
    }
    
    func presentError(_ error: AppError) {
        errorMessage = error.userFacingMessage
        showingError = true
    }
    
    func resetNavigation() {
        dashboardPath = NavigationPath()
        watchlistPath = NavigationPath()
    }
}
