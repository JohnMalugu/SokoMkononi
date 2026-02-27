import Foundation
import SwiftData

// MARK: - Data Transfer Objects (DTOs)
// Used for decoding JSON and passing between layers

struct CropDTO: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let category: String
    let currentPrice: Double
    let unit: String
    let region: String
    let trend: String
    let history: [PriceHistoryDTO]
    
    enum CodingKeys: String, CodingKey {
        case id, name, category, unit, region, trend, history
        case currentPrice = "current_price"
    }
    
    var trendDirection: TrendDirection {
        TrendDirection(rawValue: trend) ?? .stable
    }
    
    var regionEnum: Region {
        Region.allCases.first { $0.rawValue.lowercased() == region.lowercased() } ?? .all
    }
}

struct PriceHistoryDTO: Codable, Hashable {
    let date: String
    let price: Double
    
    var parsedDate: Date? {
        ISO8601DateFormatter.shortDate.date(from: date)
    }
}

// MARK: - Enumerations

enum TrendDirection: String, Codable {
    case up, down, stable
    
    var systemImage: String {
        switch self {
        case .up: return "arrow.up.circle.fill"
        case .down: return "arrow.down.circle.fill"
        case .stable: return "minus.circle.fill"
        }
    }
    
    var color: String {
        switch self {
        case .up: return "TrendUp"
        case .down: return "TrendDown"
        case .stable: return "TrendStable"
        }
    }
    
    var label: String {
        switch self {
        case .up: return "Inapanda"
        case .down: return "Inashuka"
        case .stable: return "Imara"
        }
    }
}

enum Region: String, CaseIterable, Codable {
    case all = "Zote"
    case darEsSalaam = "Dar es Salaam"
    case arusha = "Arusha"
    case mbeya = "Mbeya"
    case dodoma = "Dodoma"
    case mtwara = "Mtwara"
    case morogoro = "Morogoro"
    case mwanza = "Mwanza"
    
    var displayName: String { rawValue }
}

enum CropCategory: String, CaseIterable {
    case all = "Zote"
    case cereals = "Cereals"
    case nuts = "Nuts"
    case vegetables = "Vegetables"
    case fruits = "Fruits"
    case legumes = "Legumes"
}

// MARK: - SwiftData Persistent Models

@Model
final class CropModel {
    @Attribute(.unique) var id: String
    var name: String
    var category: String
    var currentPrice: Double
    var unit: String
    var region: String
    var trend: String
    var lastUpdated: Date
    var isSaved: Bool
    
    @Relationship(deleteRule: .cascade)
    var priceHistory: [PriceHistoryModel] = []
    
    init(from dto: CropDTO) {
        self.id = dto.id
        self.name = dto.name
        self.category = dto.category
        self.currentPrice = dto.currentPrice
        self.unit = dto.unit
        self.region = dto.region
        self.trend = dto.trend
        self.lastUpdated = Date()
        self.isSaved = false
    }
    
    func toDTO() -> CropDTO {
        CropDTO(
            id: id,
            name: name,
            category: category,
            currentPrice: currentPrice,
            unit: unit,
            region: region,
            trend: trend,
            history: priceHistory.sorted { $0.date < $1.date }.map { $0.toDTO() }
        )
    }
    
    func update(from dto: CropDTO) {
        self.currentPrice = dto.currentPrice
        self.trend = dto.trend
        self.lastUpdated = Date()
    }
}

@Model
final class PriceHistoryModel {
    var date: String
    var price: Double
    
    init(from dto: PriceHistoryDTO) {
        self.date = dto.date
        self.price = dto.price
    }
    
    func toDTO() -> PriceHistoryDTO {
        PriceHistoryDTO(date: date, price: price)
    }
}

@Model
final class AppSettingsModel {
    @Attribute(.unique) var key: String
    var value: String
    
    init(key: String, value: String) {
        self.key = key
        self.value = value
    }
}
