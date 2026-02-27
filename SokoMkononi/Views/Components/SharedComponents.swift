import SwiftUI

// MARK: - Loading View

struct LoadingView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.4)
                .tint(AppTheme.primary)
            
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Empty State View

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 56))
                .foregroundStyle(AppTheme.primary.opacity(0.4))
            
            VStack(spacing: 6) {
                Text(title)
                    .font(.headline)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.bordered)
                    .tint(AppTheme.primary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Error State View

struct ErrorStateView: View {
    let error: AppError
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 52))
                .foregroundStyle(.orange)
            
            VStack(spacing: 8) {
                Text("Samahani!")
                    .font(.title3.bold())
                
                Text(error.userFacingMessage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            if error.isRecoverable {
                Button {
                    retryAction()
                } label: {
                    Label("Jaribu Tena", systemImage: "arrow.clockwise")
                        .font(.subheadline.weight(.semibold))
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.primary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Offline Banner

struct OfflineBannerView: View {
    let lastUpdated: Date?
    @State private var isExpanded = false
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                isExpanded.toggle()
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "wifi.slash")
                    .font(.caption.bold())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Hali ya nje ya mtandao")
                        .font(.caption.bold())
                    
                    if isExpanded, let date = lastUpdated {
                        Text("Ilisasishwa: \(date.formatted(.relative(presentation: .named)))")
                            .font(.caption2)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                
                Spacer()
                
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.caption2)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .foregroundStyle(.white)
        }
        .background(Color.orange)
    }
}

// MARK: - Network Status Icon

struct NetworkStatusIcon: View {
    @ObservedObject private var monitor = NetworkMonitor.shared
    
    var body: some View {
        Image(systemName: monitor.isConnected ? monitor.connectionType.icon : "wifi.slash")
            .font(.caption)
            .foregroundStyle(monitor.isConnected ? .green : .orange)
            .animation(.easeInOut, value: monitor.isConnected)
    }
}

// MARK: - Filter Chips

struct RegionPickerChip: View {
    @Binding var selected: Region
    
    var body: some View {
        Menu {
            Picker("Mkoa", selection: $selected) {
                ForEach(Region.allCases, id: \.self) { region in
                    Text(region.displayName).tag(region)
                }
            }
        } label: {
            FilterChipLabel(
                text: selected == .all ? "Mkoa Wote" : selected.displayName,
                icon: "mappin.circle",
                isActive: selected != .all
            )
        }
    }
}

struct CategoryPickerChip: View {
    @Binding var selected: CropCategory
    
    var body: some View {
        Menu {
            Picker("Aina", selection: $selected) {
                ForEach(CropCategory.allCases, id: \.self) { cat in
                    Text(cat.rawValue).tag(cat)
                }
            }
        } label: {
            FilterChipLabel(
                text: selected == .all ? "Aina Zote" : selected.rawValue,
                icon: "leaf.circle",
                isActive: selected != .all
            )
        }
    }
}

struct SortChip: View {
    @Binding var selected: SortOption
    
    var body: some View {
        Menu {
            Picker("Panga", selection: $selected) {
                ForEach(SortOption.allCases, id: \.self) { opt in
                    Text(opt.rawValue).tag(opt)
                }
            }
        } label: {
            FilterChipLabel(
                text: selected.rawValue,
                icon: "arrow.up.arrow.down.circle",
                isActive: selected != .nameAscending
            )
        }
    }
}

struct FilterChipLabel: View {
    let text: String
    let icon: String
    let isActive: Bool
    
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.caption.weight(.medium))
            Image(systemName: "chevron.down")
                .font(.system(size: 8, weight: .bold))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(isActive ? AppTheme.primary : AppTheme.cardBackground)
        .foregroundStyle(isActive ? .white : .primary)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 1)
    }
}
