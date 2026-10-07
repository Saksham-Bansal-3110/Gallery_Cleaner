import Foundation

let path = "Gallery Cleaner/Services/Similarity/PhotoRankingService.swift"
var content = try! String(contentsOfFile: path)
content = content.replacingOccurrences(of: """
        for item in items {
            var score = 0.0
            var reasons = [QualityReason]()
            
            let asset = item.asset
            
            // 1. Favorite
            if asset.isFavorite {
                score += 1000.0
                reasons.append(.favorite)
            }
            
            // 2. Resolution
            let resolution = item.pixelWidth * item.pixelHeight
            if resolution > 0 && resolution == maxResolution {
                score += 500.0
                reasons.append(.higherResolution)
            } else if resolution > 0 {
                // proportional score for resolution
                score += 500.0 * (Double(resolution) / Double(maxResolution))
            }
            
            // 3. Edited status (Proxy: mod date differs significantly from creation date)
            if let modDate = item.modificationDate, let creDate = item.creationDate, modDate.timeIntervalSince(creDate) > 60 {
                score += 200.0
                reasons.append(.edited)
            }
            
            // 4. Live Photo
            if asset.mediaSubtypes.contains(.photoLive) {
                score += 100.0
                reasons.append(.livePhoto)
            }
            
            // 5. Recency (Weak tie breaker)
            if let creDate = item.creationDate {
                let normalized = (creDate.timeIntervalSinceReferenceDate - oldestDate) / dateRange
                score += normalized * 10.0
                if normalized > 0.9 {
                    reasons.append(.newerTieBreaker)
                }
            }
            
            if reasons.isEmpty {
                reasons.append(.baseline)
            }
            
            scores[item.id] = PhotoQualityScore(localIdentifier: item.id, score: score, reasons: reasons)
        }
""", with: """
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
""")

let methodInjection = """
    
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
"""

content = content.replacingOccurrences(of: """
        return (recommended, rankedItems)
    }
}
""", with: """
        return (recommended, rankedItems)
    }
\(methodInjection)
""")

try! content.write(toFile: path, atomically: true, encoding: .utf8)
