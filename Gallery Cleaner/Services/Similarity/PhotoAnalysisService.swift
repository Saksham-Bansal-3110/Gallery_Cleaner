import Foundation
import Photos
import SwiftData



public actor PhotoAnalysisService {
    private let cache: PhotoAnalysisCache
    private let perceptualService = PerceptualHashService()
    private let visionService = VisionFeatureService()
    
        // Diagnostics
    public var totalRequested: Int = 0
    public var dHashSuccesses: Int = 0
    public var dHashFailures: Int = 0
    public var visionSuccesses: Int = 0
    public var visionFailures: Int = 0
    public var cacheHits: Int = 0
    public var cacheMisses: Int = 0
    public var totalAnalysisTime: TimeInterval = 0
    public var peakConcurrentCount: Int = 0
    private var currentConcurrentCount: Int = 0
    
    public init(cache: PhotoAnalysisCache) {
        self.cache = cache
    }
    
    public func analyze(assets: [PHAsset]) async -> [PhotoAnalysisResult] {
        let startTime = Date()
        var results: [PhotoAnalysisResult] = []
        
        await withTaskGroup(of: PhotoAnalysisResult?.self) { group in
            let maxConcurrent = SimilarityConfiguration.shared.maxVisionConcurrentTasks
            var i = 0
            
            while i < min(maxConcurrent, assets.count) {
                let asset = assets[i]
                group.addTask { await self.analyzeSingle(asset: asset) }
                i += 1
            }
            
            for await result in group {
                if let r = result {
                    results.append(r)
                }
                if i < assets.count {
                    let asset = assets[i]
                    group.addTask { await self.analyzeSingle(asset: asset) }
                    i += 1
                }
            }
        }
        
        totalAnalysisTime = Date().timeIntervalSince(startTime)
        
        #if DEBUG
        print("--- PHOTO ANALYSIS DIAGNOSTICS ---")
        print("Total Requested: \(totalRequested)")
        print("Cache Hits: \(cacheHits) | Misses: \(cacheMisses)")
        print("dHash Successes: \(dHashSuccesses) | Failures: \(dHashFailures)")
        print("Vision Successes: \(visionSuccesses) | Failures: \(visionFailures)")
        print("Peak Concurrent Tasks: \(peakConcurrentCount)")
        print("Total Duration: \(String(format: "%.2f", totalAnalysisTime))s")
        print("----------------------------------")
        #endif
        
        return results
    }
    
    private func analyzeSingle(asset: PHAsset) async -> PhotoAnalysisResult? {
        totalRequested += 1
                currentConcurrentCount += 1
        peakConcurrentCount = max(peakConcurrentCount, currentConcurrentCount)
        defer {         currentConcurrentCount = max(0, currentConcurrentCount - 1) }
        
        // 1. Cache Check
        if let cached = await cache.getCachedAnalysis(for: asset) {
            cacheHits += 1
            return cached
        }
        
        cacheMisses += 1
        
        // 2. Perceptual Hash
        let dHash: UInt64
        do {
            dHash = try await perceptualService.generateDHash(for: asset)
            dHashSuccesses += 1
        } catch {
            dHashFailures += 1
            return nil // graceful fail
        }
        
        // 3. Vision Feature
        let visionFeature: VisionFeatureResult
        do {
            visionFeature = try await visionService.generateVisionFeature(for: asset)
            visionSuccesses += 1
        } catch {
            visionFailures += 1
            return nil // graceful fail
        }
        
        let result = PhotoAnalysisResult(
            localIdentifier: asset.localIdentifier,
            modificationDate: asset.modificationDate ?? Date(),
            pixelWidth: asset.pixelWidth,
            pixelHeight: asset.pixelHeight,
            aspectRatio: Float(asset.pixelWidth) / Float(max(1, asset.pixelHeight)),
            perceptualHash: dHash,
            visionFeatureData: visionFeature.data,
            visionElementType: visionFeature.elementType,
            visionElementCount: visionFeature.elementCount,
            visionRevision: visionFeature.revision
        )
        
        // 4. Cache Save
        await cache.saveAnalysis(result)
        
        return result
    }
}
