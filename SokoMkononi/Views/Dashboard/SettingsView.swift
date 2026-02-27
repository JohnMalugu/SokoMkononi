import SwiftUI
import SwiftData

struct SettingsView: View {
    
    @Environment(\.modelContext) private var modelContext
    @ObservedObject private var networkMonitor = NetworkMonitor.shared
    @AppStorage("preferredRegion") private var preferredRegion: String = Region.all.rawValue
    @AppStorage("preferredCurrency") private var preferredCurrency: String = "TZS"
    @AppStorage("enableNotifications") private var enableNotifications: Bool = false
    @State private var showingClearCacheAlert = false
    @State private var cacheCleared = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                List {
                    networkSection
                    preferencesSection
                    dataSection
                    aboutSection
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("⚙️ Mipangilio")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - Network Section
    
    private var networkSection: some View {
        Section("Hali ya Mtandao") {
            HStack {
                Image(systemName: networkMonitor.connectionType.icon)
                    .foregroundStyle(networkMonitor.isConnected ? Color.green : Color.red)
                    .frame(width: 28)
                
                Text(networkMonitor.isConnected ? "Imeunganishwa" : "Hakuna Mtandao")
                    .foregroundColor(networkMonitor.isConnected ? .primary : .red)
                
                Spacer()
                
                Circle()
                    .fill(networkMonitor.isConnected ? Color.green : Color.red)
                    .frame(width: 10, height: 10)
            }
        }
    }
    
    // MARK: - Preferences Section
    
    private var preferencesSection: some View {
        Section("Mapendeleo") {
            // Default Region
            Picker(selection: $preferredRegion) {
                ForEach(Region.allCases, id: \.rawValue) { region in
                    Text(region.displayName).tag(region.rawValue)
                }
            } label: {
                Label("Mkoa wa Msingi", systemImage: "mappin.circle")
            }
            
            // Notifications toggle
            Toggle(isOn: $enableNotifications) {
                Label("Arifa za Bei", systemImage: "bell.badge")
            }
            .tint(AppTheme.primary)
        }
    }
    
    // MARK: - Data Section
    
    private var dataSection: some View {
        Section("Data") {
            Button {
                showingClearCacheAlert = true
            } label: {
                Label("Futa Cache", systemImage: "trash.circle")
                    .foregroundStyle(.red)
            }
            .alert("Futa Cache?", isPresented: $showingClearCacheAlert) {
                Button("Futa", role: .destructive) {
                    clearCache()
                }
                Button("Ghairi", role: .cancel) {}
            } message: {
                Text("Hii itafuta data yote iliyohifadhiwa. Utahitaji muunganiko wa intaneti kupakia data upya.")
            }
            
            if cacheCleared {
                Label("Cache imefutwa", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
        }
    }
    
    // MARK: - About Section
    
    private var aboutSection: some View {
        Section("Kuhusu") {
            LabeledContent("Toleo", value: "1.0.0")
            LabeledContent("Lugha", value: "Kiswahili / English")
            
            Link(destination: URL(string: "https://github.com")!) {
                Label("Chanzo cha Data", systemImage: "link")
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Soko Mkononi")
                    .font(.subheadline.bold())
                Text("Thamani ya mazao kwa urahisi")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
        }
    }
    
    private func clearCache() {
        do {
            try modelContext.delete(model: CropModel.self)
            try modelContext.save()
            withAnimation { cacheCleared = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                cacheCleared = false
            }
        } catch {
            print("Failed to clear cache: \(error)")
        }
    }
}

#Preview { SettingsView() }
