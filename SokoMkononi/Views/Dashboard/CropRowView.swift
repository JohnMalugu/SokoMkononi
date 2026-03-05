import SwiftUI

struct CropRowView: View {
    let crop: CropDTO
    
    var body: some View {
        HStack(spacing: 12) {
            // Category Icon
            categoryIcon
            
            // Main Info
            VStack(alignment: .leading, spacing: 4) {
                
                Text(crop.name)
                    .font(.system(.body, design: .rounded, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)

                Text(crop.category)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Color.green.opacity(0.8))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(Color.green.opacity(0.15))
                            .overlay(
                                Capsule()
                                    .stroke(Color.green.opacity(0.4), lineWidth: 1)
                            )
                    )

                Label(crop.region, systemImage: "mappin.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)

            }
            
            Spacer()
            
            // Price & Trend
            VStack(alignment: .trailing, spacing: 4) {
                Text(crop.currentPrice.formattedAsTZS(unit: crop.unit))
                    .font(.system(.subheadline, design: .monospaced, weight: .bold))
                    .foregroundStyle(AppTheme.textPrimary)
                
                TrendBadge(trend: crop.trendDirection)
            }
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(AppTheme.cardBackground)
                .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
        )
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
    
    private var categoryIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(AppTheme.primary.opacity(0.12))
                .frame(width: 46, height: 46)
            
            Text(crop.category.categoryEmoji)
                .font(.title3)
        }
    }
}

// MARK: - Trend Badge

struct TrendBadge: View {
    let trend: TrendDirection
    
    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: trend.systemImage)
                .font(.system(size: 10, weight: .bold))
            Text(trend.label)
                .font(.system(size: 10, weight: .semibold))
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 3)
        .background(
            Capsule()
                .fill(trendColor.opacity(0.15))
        )
        .foregroundStyle(trendColor)
    }
    
    private var trendColor: Color {
        switch trend {
        case .up: return .green
        case .down: return .red
        case .stable: return .orange
        }
    }
}

// MARK: - Preview

#Preview {
    VStack {
        CropRowView(crop: CropDTO.mockData[0])
        CropRowView(crop: CropDTO.mockData[1])
    }
    .padding()
    .background(AppTheme.background)
}
