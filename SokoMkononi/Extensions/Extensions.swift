import Foundation
import SwiftUI

// MARK: - Double Extensions

extension Double {
    /// Format as Tanzanian Shilling (TZS)
    func formattedAsTZS(unit: String = "") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.maximumFractionDigits = 0
        let formatted = formatter.string(from: NSNumber(value: self)) ?? "\(Int(self))"
        
        if unit.isEmpty {
            return "TZS \(formatted)"
        } else {
            return "TZS \(formatted)/\(unit)"
        }
    }
    
    /// Short format (e.g., 1,200 → 1.2K)
    var shortFormatted: String {
        switch self {
        case 1_000_000...: return String(format: "%.1fM", self / 1_000_000)
        case 1_000...: return String(format: "%.1fK", self / 1_000)
        default: return String(format: "%.0f", self)
        }
    }
    
    func formattedAsTZS() -> String { formattedAsTZS(unit: "") }
}

// MARK: - String Extensions

extension String {
    var categoryEmoji: String {
        switch self.lowercased() {
        case "cereals": return "🌽"
        case "nuts": return "🥜"
        case "vegetables": return "🥦"
        case "fruits": return "🍎"
        case "legumes": return "🫘"
        case "spices": return "🌶️"
        default: return "🌾"
        }
    }
}

// MARK: - ISO8601DateFormatter

extension ISO8601DateFormatter {
    static let shortDate: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return formatter
    }()
}

// MARK: - Date Extensions

extension Date {
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    var isWithinLastHour: Bool {
        Date().timeIntervalSince(self) < 3600
    }
    
    var relativeLabel: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "sw")
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

// MARK: - View Extensions

extension View {
    func cardStyle(cornerRadius: CGFloat = 12) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(AppTheme.cardBackground)
                    .shadow(color: .black.opacity(0.07), radius: 6, x: 0, y: 3)
            )
    }
    
    func shimmer(isActive: Bool) -> some View {
        self.redacted(reason: isActive ? .placeholder : [])
    }
}
