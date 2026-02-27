import Foundation

// MARK: - Network Service Protocol (enables mocking/testing)

protocol CropDataServiceProtocol {
    func fetchCrops() async throws -> [CropDTO]
    func fetchCrop(id: String) async throws -> CropDTO
}

// MARK: - Live Network Service

final class CropNetworkService: CropDataServiceProtocol {
    
    static let shared = CropNetworkService()
    
    private let session: URLSession
    private let decoder: JSONDecoder
    
    // Remote URL (can be GitHub Gist or Mockaroo)
    private let remoteURL = URL(string: "https://raw.githubusercontent.com/placeholder/soko-data/main/crops.json")!
    
    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
    }
    
    // MARK: - Fetch All Crops
    
    func fetchCrops() async throws -> [CropDTO] {
        // Try remote first, fall back to local bundle
        do {
            return try await fetchFromRemote()
        } catch AppError.networkUnavailable {
            return try loadLocalBundle()
        } catch {
            // If remote fails for any reason, try local
            if let local = try? loadLocalBundle() {
                return local
            }
            throw error
        }
    }
    
    func fetchCrop(id: String) async throws -> CropDTO {
        let crops = try await fetchCrops()
        guard let crop = crops.first(where: { $0.id == id }) else {
            throw AppError.dataNotFound
        }
        return crop
    }
    
    // MARK: - Private Helpers
    
    private func fetchFromRemote() async throws -> [CropDTO] {
        guard NetworkMonitor.shared.isConnected else {
            throw AppError.networkUnavailable
        }
        
        let (data, response) = try await session.data(from: remoteURL)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AppError.unknown(URLError(.badServerResponse))
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw AppError.serverError(httpResponse.statusCode)
        }
        
        do {
            return try decoder.decode([CropDTO].self, from: data)
        } catch {
            throw AppError.decodingFailed(error.localizedDescription)
        }
    }
    
    private func loadLocalBundle() throws -> [CropDTO] {
        guard let url = Bundle.main.url(forResource: "crops", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            throw AppError.dataNotFound
        }
        
        do {
            return try decoder.decode([CropDTO].self, from: data)
        } catch {
            throw AppError.decodingFailed(error.localizedDescription)
        }
    }
}

// MARK: - Mock Service for Previews and Tests

final class MockCropService: CropDataServiceProtocol {
    var mockCrops: [CropDTO] = CropDTO.mockData
    var shouldFail = false
    var failureError: AppError = .networkUnavailable
    
    func fetchCrops() async throws -> [CropDTO] {
        try await Task.sleep(nanoseconds: 500_000_000) // Simulate network
        if shouldFail { throw failureError }
        return mockCrops
    }
    
    func fetchCrop(id: String) async throws -> CropDTO {
        let crops = try await fetchCrops()
        guard let crop = crops.first(where: { $0.id == id }) else {
            throw AppError.dataNotFound
        }
        return crop
    }
}
