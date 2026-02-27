import Network
import Foundation
import Combine

// MARK: - Network Monitor (Singleton)

final class NetworkMonitor: ObservableObject {
    
    static let shared = NetworkMonitor()
    
    @Published private(set) var isConnected: Bool = true
    @Published private(set) var connectionType: ConnectionType = .unknown
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.sokomkononi.network", qos: .utility)
    
    private init() {
        startMonitoring()
    }
    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                self?.connectionType = self?.resolveConnectionType(path) ?? .unknown
            }
        }
        monitor.start(queue: queue)
    }
    
    private func resolveConnectionType(_ path: NWPath) -> ConnectionType {
        if path.usesInterfaceType(.wifi) { return .wifi }
        if path.usesInterfaceType(.cellular) { return .cellular }
        if path.usesInterfaceType(.wiredEthernet) { return .ethernet }
        return .unknown
    }
    
    deinit { monitor.cancel() }
    
    enum ConnectionType {
        case wifi, cellular, ethernet, unknown
        
        var icon: String {
            switch self {
            case .wifi: return "wifi"
            case .cellular: return "antenna.radiowaves.left.and.right"
            case .ethernet: return "cable.connector"
            case .unknown: return "wifi.slash"
            }
        }
    }
}
