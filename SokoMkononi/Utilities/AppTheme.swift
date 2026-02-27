import SwiftUI

// MARK: - App Theme (Design System)
// Uses hardcoded colors — no Assets.xcassets required

enum AppTheme {

    // MARK: - Brand Colors
    static let primary        = Color(hex: "#2E7D32")   // Forest green
    static let secondary      = Color(hex: "#F59E0B")   // Amber

    // MARK: - Backgrounds (adaptive light/dark)
    static let background     = Color(.systemGroupedBackground)
    static let cardBackground = Color(.secondarySystemGroupedBackground)

    // MARK: - Text
    static let textPrimary    = Color(.label)
    static let textSecondary  = Color(.secondaryLabel)

    // MARK: - Trend Colors
    static let trendUp        = Color(hex: "#22C55E")
    static let trendDown      = Color(hex: "#EF4444")
    static let trendStable    = Color(hex: "#F59E0B")
}

// MARK: - Hex Color Initializer

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b, a: UInt64
        switch hex.count {
        case 6: // RGB
            (r, g, b, a) = (int >> 16, int >> 8 & 0xFF, int & 0xFF, 255)
        case 8: // RGBA
            (r, g, b, a) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b, a) = (0, 0, 0, 255)
        }
        self.init(
            .sRGB,
            red:   Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
