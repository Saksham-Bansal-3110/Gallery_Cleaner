import Foundation
import Photos

public enum QualityReason: String, CustomStringConvertible, Sendable {
    case favorite = "Favorite"
    case higherResolution = "High Resolution"
    case edited = "Edited"
    case livePhoto = "Live Photo"
    case newerTieBreaker = "Newer"
    case baseline = "Baseline"
    
    public var description: String { return self.rawValue }
}

public struct PhotoQualityScore: Sendable {
    public let localIdentifier: String
    public let score: Double
    public let reasons: [QualityReason]
}

@preconcurrency public struct PhotoRankingDiagnostics: Sendable {
    public var groupsRanked: Int = 0
    public var totalRankingTime: TimeInterval = 0
    public var recommendationReasons: [QualityReason: Int] = [:]
    
    nonisolated public init() {}
    

}

public actor PhotoRankingService {
    public var diagnostics = PhotoRankingDiagnostics()
    
    public init() {}
    
    public func rank(items: [MediaItem]) -> (recommended: MediaItem, rankedItems: [MediaItem]) {
        guard items.count > 1 else {
            return (items.first!, items)
        }
        
        let startTime = Date()
        
        let maxResolution = items.map { $0.pixelWidth * $0.pixelHeight }.max() ?? 0
        let newestDate = items.compactMap { $0.creationDate }.max()?.timeIntervalSinceReferenceDate ?? 0
        let oldestDate = items.compactMap { $0.creationDate }.min()?.timeIntervalSinceReferenceDate ?? 0
        let dateRange = max(1.0, newestDate - oldestDate)
        
        var scores = [String: PhotoQualityScore]()
        
        for item in items {
            let asset = item.asset
            let isFavorite = asset.isFavorite
            let resolution = item.pixelWidth * item.pixelHeight
            let isEdited = (item.modificationDate != nil && item.creationDate != nil && item.modificationDate!.timeIntervalSince(item.creationDate!) > 60)
            let isLive = asset.mediaSubtypes.contains(.photoLive)
            let creationTime = item.creationDate?.timeIntervalSinceReferenceDate ?? 0
            
            let scoreResult = PhotoRankingService.computeScore(
                id: item.id,
                isFavorite: isFavorite,
                resolution: resolution,
                maxResolution: maxResolution,
                isEdited: isEdited,
                isLive: isLive,
                creationTime: creationTime,
                oldestTime: oldestDate,
                timeRange: dateRange
            )
            scores[item.id] = scoreResult
        }
        
        // Sort items by score descending. If scores equal, fallback to ID for determinism.
        let rankedItems = items.sorted { a, b in
            let scoreA = scores[a.id]?.score ?? 0
            let scoreB = scores[b.id]?.score ?? 0
            if abs(scoreA - scoreB) > 0.001 {
                return scoreA > scoreB
            }
            return a.id > b.id
        }
        
        let recommended = rankedItems.first!
        let topReasons = scores[recommended.id]?.reasons ?? []
        
        let elapsed = Date().timeIntervalSince(startTime)
        diagnostics.groupsRanked += 1
        diagnostics.totalRankingTime += elapsed
        for r in topReasons {
            diagnostics.recommendationReasons[r, default: 0] += 1
        }
        
        return (recommended, rankedItems)
    }
    
    public static func computeScore(
        id: String,
        isFavorite: Bool,
        resolution: Int,
        maxResolution: Int,
        isEdited: Bool,
        isLive: Bool,
        creationTime: TimeInterval,
        oldestTime: TimeInterval,
        timeRange: TimeInterval
    ) -> PhotoQualityScore {
        var score = 0.0
        var reasons = [QualityReason]()
        
        if isFavorite {
            score += 1000.0
            reasons.append(.favorite)
        }
        
        if resolution > 0 && resolution == maxResolution {
            score += 500.0
            reasons.append(.higherResolution)
        } else if resolution > 0 && maxResolution > 0 {
            score += 500.0 * (Double(resolution) / Double(maxResolution))
        }
        
        if isEdited {
            score += 200.0
            reasons.append(.edited)
        }
        
        if isLive {
            score += 100.0
            reasons.append(.livePhoto)
        }
        
        if creationTime > 0 && timeRange > 0 {
            let normalized = (creationTime - oldestTime) / timeRange
            score += normalized * 10.0
            if normalized > 0.9 {
                reasons.append(.newerTieBreaker)
            }
        }
        
        if reasons.isEmpty {
            reasons.append(.baseline)
        }
        
        return PhotoQualityScore(localIdentifier: id, score: score, reasons: reasons)
    }
}
