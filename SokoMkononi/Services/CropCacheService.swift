import Foundation
import SwiftData

// MARK: - Cache Service

@MainActor
final class CropCacheService {
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Save Crops to Cache
    
    func cacheCrops(_ dtos: [CropDTO]) throws {
        for dto in dtos {
            let fetchDescriptor = FetchDescriptor<CropModel>(
                predicate: #Predicate { $0.id == dto.id }
            )
            
            if let existing = try? modelContext.fetch(fetchDescriptor).first {
                // Update existing
                existing.update(from: dto)
                updateHistory(for: existing, from: dto)
            } else {
                // Insert new
                let model = CropModel(from: dto)
                modelContext.insert(model)
                insertHistory(for: model, from: dto)
            }
        }
        
        try modelContext.save()
    }
    
    // MARK: - Load from Cache
    
    func loadCachedCrops(region: Region = .all, category: CropCategory = .all) throws -> [CropDTO] {
        let regionValue = region.rawValue
        let categoryValue = category.rawValue
        
        var descriptor = FetchDescriptor<CropModel>(
            sortBy: [SortDescriptor(\.name)]
        )
        
        // Apply filters
        if region != .all && category != .all {
            descriptor.predicate = #Predicate {
                $0.region == regionValue && $0.category == categoryValue
            }
        } else if region != .all {
            descriptor.predicate = #Predicate { $0.region == regionValue }
        } else if category != .all {
            descriptor.predicate = #Predicate { $0.category == categoryValue }
        }
        
        let models = try modelContext.fetch(descriptor)
        return models.map { $0.toDTO() }
    }
    
    // MARK: - Watchlist Management
    
    func savedCrops() throws -> [CropDTO] {
        let descriptor = FetchDescriptor<CropModel>(
            predicate: #Predicate { $0.isSaved == true },
            sortBy: [SortDescriptor(\.name)]
        )
        let models = try modelContext.fetch(descriptor)
        return models.map { $0.toDTO() }
    }
    
    func toggleSave(cropId: String) throws -> Bool {
        let descriptor = FetchDescriptor<CropModel>(
            predicate: #Predicate { $0.id == cropId }
        )
        guard let model = try modelContext.fetch(descriptor).first else {
            throw AppError.dataNotFound
        }
        model.isSaved.toggle()
        try modelContext.save()
        return model.isSaved
    }
    
    func isSaved(cropId: String) throws -> Bool {
        let descriptor = FetchDescriptor<CropModel>(
            predicate: #Predicate { $0.id == cropId }
        )
        return try modelContext.fetch(descriptor).first?.isSaved ?? false
    }
    
    // MARK: - Cache Metadata
    
    func lastUpdated() throws -> Date? {
        let descriptor = FetchDescriptor<CropModel>(
            sortBy: [SortDescriptor(\.lastUpdated, order: .reverse)]
        )
        var limited = descriptor
        limited.fetchLimit = 1
        return try modelContext.fetch(limited).first?.lastUpdated
    }
    
    func clearCache() throws {
        try modelContext.delete(model: CropModel.self)
        try modelContext.save()
    }
    
    // MARK: - Private Helpers
    
    private func updateHistory(for model: CropModel, from dto: CropDTO) {
        // Replace history
        for old in model.priceHistory { modelContext.delete(old) }
        model.priceHistory = dto.history.map { PriceHistoryModel(from: $0) }
    }
    
    private func insertHistory(for model: CropModel, from dto: CropDTO) {
        model.priceHistory = dto.history.map { PriceHistoryModel(from: $0) }
    }
}

