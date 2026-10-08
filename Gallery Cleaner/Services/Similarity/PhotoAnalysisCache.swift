import Foundation
import SwiftData
import Photos

public struct CachedAnalysis: Sendable {
    public let result: PhotoAnalysisResult
    public let algorithmVersion: Int
}

extension PhotoAnalysisResult: Sendable {}

@ModelActor
public actor PhotoAnalysisCache {
    private var inMemoryCache = [String: CachedAnalysis]()
    private let maxMemoryCacheCount = 1000
    private var cacheQueue = [String]()
    
    public func getCachedAnalysis(for asset: PHAsset) -> PhotoAnalysisResult? {
        let identifier = asset.localIdentifier
        
        // 1. Check in-memory cache
        if let cached = inMemoryCache[identifier], isValid(cached, for: asset) {
            return cached.result
        }
        
        // 2. Check SwiftData
        let descriptor = FetchDescriptor<AssetAnalysisData>(
            predicate: #Predicate { $0.localIdentifier == identifier }
        )
        
        do {
            if let cachedData = try modelContext.fetch(descriptor).first {
                let cached = CachedAnalysis(result: cachedData.toResult(), algorithmVersion: cachedData.algorithmVersion)
                if isValid(cached, for: asset) {
                    addToMemoryCache(cached)
                    return cached.result
                } else {
                    modelContext.delete(cachedData)
                    inMemoryCache.removeValue(forKey: identifier)
                    try modelContext.save()
                }
            }
        } catch {
            print("PhotoAnalysisCache: Fetch error - \(error)")
        }
        return nil
    }
    
    public func saveAnalysis(_ result: PhotoAnalysisResult) {
        let algoVersion = SimilarityConfiguration.shared.algorithmVersion
        let data = AssetAnalysisData(result: result, algorithmVersion: algoVersion)
        
        let cached = CachedAnalysis(result: result, algorithmVersion: algoVersion)
        addToMemoryCache(cached)
        
        modelContext.insert(data)
        do {
            try modelContext.save()
        } catch {
            print("PhotoAnalysisCache: Save error - \(error)")
        }
    }
    
    private func addToMemoryCache(_ cached: CachedAnalysis) {
        let identifier = cached.result.localIdentifier
        if inMemoryCache[identifier] == nil {
            cacheQueue.append(identifier)
        }
        inMemoryCache[identifier] = cached
        
        if cacheQueue.count > maxMemoryCacheCount {
            let oldest = cacheQueue.removeFirst()
            inMemoryCache.removeValue(forKey: oldest)
        }
    }
    
    private func isValid(_ cached: CachedAnalysis, for asset: PHAsset) -> Bool {
        let data = cached.result
        if data.pixelWidth != asset.pixelWidth || data.pixelHeight != asset.pixelHeight { return false }
        if let assetModDate = asset.modificationDate, data.modificationDate != assetModDate { return false }
        if data.visionRevision != SimilarityConfiguration.shared.currentVisionRevision { return false }
        if cached.algorithmVersion != SimilarityConfiguration.shared.algorithmVersion { return false }
        return true
    }
}