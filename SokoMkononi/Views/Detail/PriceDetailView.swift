import SwiftUI
import Charts
import SwiftData

struct PriceDetailView: View {
    
    let crop: CropDTO
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: PriceDetailViewModel
    
    init(crop: CropDTO) {
        self.crop = crop
        // Will be re-initialized with proper context in onAppear
        _viewModel = StateObject(wrappedValue: PriceDetailViewModel(
            crop: crop,
            cacheService: CropCacheService(modelContext: ModelContext(try! ModelContainer(for: CropModel.self, PriceHistoryModel.self)))
        ))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerCard
                timeRangePicker
                priceChart
                statsGrid
                marketComparison
            }
            .padding(.bottom, 32)
        }
        .background(AppTheme.background)
        .navigationTitle(crop.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        viewModel.toggleWatchlist()
                    }
                } label: {
                    Image(systemName: viewModel.isSaved ? "bookmark.fill" : "bookmark")
                        .symbolEffect(.bounce, value: viewModel.isSaved)
                        .foregroundStyle(viewModel.isSaved ? AppTheme.primary : .primary)
                }
            }
        }
    }
    
    // MARK: - Header Card
    
    private var headerCard: some View {
        VStack(spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(crop.name)
                        .font(.title2.bold())
                    
                    Label(crop.region, systemImage: "mappin.circle.fill")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(crop.currentPrice.formattedAsTZS(unit: crop.unit))
                        .font(.system(.title, design: .monospaced, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)
                    
                    TrendBadge(trend: crop.trendDirection)
                }
            }
            
            if let stats = viewModel.priceStats {
                Divider()
                HStack {
                    statItem(label: "Chini", value: stats.min.formattedAsTZS())
                    Divider().frame(height: 30)
                    statItem(label: "Wastani", value: stats.average.formattedAsTZS())
                    Divider().frame(height: 30)
                    statItem(label: "Juu", value: stats.max.formattedAsTZS())
                }
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
        .padding(.top)
    }
    
    private func statItem(label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(.subheadline, design: .monospaced, weight: .semibold))
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Time Range Picker
    
    private var timeRangePicker: some View {
        Picker("Kipindi", selection: $viewModel.selectedTimeRange) {
            ForEach(TimeRange.allCases, id: \.self) { range in
                Text(range.label).tag(range)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }
    
    // MARK: - Price Chart
    
    @ViewBuilder
    private var priceChart: some View {
        let history = viewModel.filteredHistory
        
        VStack(alignment: .leading, spacing: 12) {
            Text(viewModel.chartTitle)
                .font(.headline)
                .padding(.horizontal)
            
            if history.isEmpty {
                ContentUnavailableView(
                    "Hakuna data",
                    systemImage: "chart.line.flattrend.xyaxis",
                    description: Text("Hakuna historia ya bei kwa kipindi hiki")
                )
                .frame(height: 200)
            } else {
                Chart {
                    ForEach(Array(history.enumerated()), id: \.offset) { index, entry in
                        LineMark(
                            x: .value("Tarehe", entry.date),
                            y: .value("Bei (TZS)", entry.price)
                        )
                        .foregroundStyle(AppTheme.primary.gradient)
                        .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round))
                        
                        AreaMark(
                            x: .value("Tarehe", entry.date),
                            y: .value("Bei (TZS)", entry.price)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppTheme.primary.opacity(0.3), .clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        
                        PointMark(
                            x: .value("Tarehe", entry.date),
                            y: .value("Bei (TZS)", entry.price)
                        )
                        .foregroundStyle(AppTheme.primary)
                        .symbolSize(40)
                    }
                }
                .frame(height: 220)
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 5)) { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        AxisValueLabel()
                            .font(.caption2)
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        AxisValueLabel {
                            if let price = value.as(Double.self) {
                                Text(price.shortFormatted)
                                    .font(.caption2)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 12)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
        .padding(.horizontal)
    }
    
    // MARK: - Stats Grid
    
    @ViewBuilder
    private var statsGrid: some View {
        if let stats = viewModel.priceStats {
            VStack(alignment: .leading, spacing: 12) {
                Text("Uchambuzi wa Bei")
                    .font(.headline)
                
                HStack(spacing: 12) {
                    StatsCardView(
                        title: "Tofauti na Wastani",
                        value: String(format: "%.1f%%", abs(stats.percentageFromAverage)),
                        subtitle: stats.isAboveAverage ? "Juu ya wastani" : "Chini ya wastani",
                        icon: stats.isAboveAverage ? "arrow.up.right.circle.fill" : "arrow.down.right.circle.fill",
                        color: stats.isAboveAverage ? .green : .red
                    )
                    
                    StatsCardView(
                        title: "Kipindi",
                        value: viewModel.selectedTimeRange.label,
                        subtitle: "\(viewModel.filteredHistory.count) siku",
                        icon: "calendar.circle.fill",
                        color: AppTheme.primary
                    )
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Market Comparison
    
    private var marketComparison: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ulinganisho wa Masoko")
                .font(.headline)
            
            VStack(spacing: 0) {
                ForEach(Array(viewModel.marketComparison.enumerated()), id: \.element.id) { index, market in
                    MarketComparisonRow(
                        market: market,
                        isHighest: index == 0,
                        isLowest: index == viewModel.marketComparison.count - 1,
                        isFirst: index == 0,
                        isLast: index == viewModel.marketComparison.count - 1
                    )
                    if index < viewModel.marketComparison.count - 1 {
                        Divider().padding(.leading, 16)
                    }
                }
            }
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
        }
        .padding(.horizontal)
    }
}

// MARK: - Market Comparison Row

struct MarketComparisonRow: View {
    let market: MarketPrice
    let isHighest: Bool
    let isLowest: Bool
    let isFirst: Bool
    let isLast: Bool
    
    var body: some View {
        HStack {
            if isHighest {
                Image(systemName: "trophy.fill")
                    .foregroundStyle(.yellow)
                    .frame(width: 20)
            } else if isLowest {
                Image(systemName: "arrow.down.circle.fill")
                    .foregroundStyle(.red.opacity(0.7))
                    .frame(width: 20)
            } else {
                Image(systemName: "circle.fill")
                    .foregroundStyle(.secondary.opacity(0.3))
                    .font(.system(size: 8))
                    .frame(width: 20)
            }
            
            Text(market.region)
                .font(.subheadline)
            
            Spacer()
            
            Text(market.price.formattedAsTZS())
                .font(.system(.subheadline, design: .monospaced, weight: .semibold))
                .foregroundStyle(isHighest ? .green : isLowest ? .red : .primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Stats Card

struct StatsCardView: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Spacer()
            }
            
            Text(value)
                .font(.title3.bold())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(color)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

#Preview {
    NavigationStack {
        PriceDetailView(crop: CropDTO.mockData[0])
    }
}
