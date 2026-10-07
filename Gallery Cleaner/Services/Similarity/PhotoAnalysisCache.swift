import Foundation
import SwiftData
import Photos

@ModelActor
public actor PhotoAnalysisCache {
    private var inMemoryCache = [String: AssetAnalysisDataWrapper]()
    private let maxMemoryCacheCount = 1000
    private var cacheQueue = [String]() // for LRU eviction
    
    public func getCachedAnalysis(for asset: PHAsset) -> PhotoAnalysisResult? {
        let identifier = asset.localIdentifier
        
        // 1. Check in-memory cache
        if let wrapper = inMemoryCache[identifier], isValid(wrapper.data, for: asset) {
            return wrapper.data.toResult()
        }
        
        // 2. Check SwiftData
        let descriptor = FetchDescriptor<AssetAnalysisData>(
            predicate: #Predicate { $0.localIdentifier == identifier }
        )
        
        do {
            if let cached = try modelContext.fetch(descriptor).first {
                if isValid(cached, for: asset) {
                    addToMemoryCache(cached)
                    return cached.toResult()
                } else {
                    // Invalidate stale cache
                    modelContext.delete(cached)
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
        let data = AssetAnalysisData(result: result, algorithmVersion: SimilarityConfiguration.shared.algorithmVersion)
        
        addToMemoryCache(data)
        
        modelContext.insert(data)
        do {
            try modelContext.save()
        } catch {
            print("PhotoAnalysisCache: Save error - \(error)")
        }
    }
    
    private func addToMemoryCache(_ data: AssetAnalysisData) {
        let identifier = data.localIdentifier
        if inMemoryCache[identifier] == nil {
            cacheQueue.append(identifier)
        }
        inMemoryCache[identifier] = AssetAnalysisDataWrapper(data: data)
        
        if cacheQueue.count > maxMemoryCacheCount {
            let oldest = cacheQueue.removeFirst()
            inMemoryCache.removeValue(forKey: oldest)
        }
    }
    
    private func isValid(_ data: AssetAnalysisData, for asset: PHAsset) -> Bool {
        if data.pixelWidth != asset.pixelWidth || data.pixelHeight != asset.pixelHeight { return false }
        if let assetModDate = asset.modificationDate, data.modificationDate != assetModDate { return false }
        if data.visionRevision != SimilarityConfiguration.shared.currentVisionRevision { return false }
        if data.algorithmVersion != SimilarityConfiguration.shared.algorithmVersion { return false }
        return true
    }
}

private class AssetAnalysisDataWrapper {
    let data: AssetAnalysisData
    init(data: AssetAnalysisData) {
        self.data = data
    }
}
