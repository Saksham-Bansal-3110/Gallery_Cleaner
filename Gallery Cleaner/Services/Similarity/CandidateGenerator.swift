import Foundation

public enum CandidateReason: String, Hashable, Sendable, CustomStringConvertible {
    case temporal
    case burst
    case dHash
    
    public var description: String { return self.rawValue }
}

public struct CandidatePair: Sendable {
    public let firstID: String
    public let secondID: String
    public var reasons: Set<CandidateReason>
    
    public init(id1: String, id2: String, reason: CandidateReason) {
        if id1 < id2 {
            self.firstID = id1
            self.secondID = id2
        } else {
            self.firstID = id2
            self.secondID = id1
        }
        self.reasons = [reason]
    }
    
}

public struct CandidateGeneratorDiagnostics {
    public var totalAnalyzed: Int = 0
    public var temporalCandidates: Int = 0
    public var burstCandidates: Int = 0
    public var dHashCandidates: Int = 0
    public var totalUniqueCandidates: Int = 0
    public var reductionRatio: Float = 0
}

public class CandidateGenerator {
    public var diagnostics = CandidateGeneratorDiagnostics()
    
    public init() {}
    
    public func generateCandidates(
        items: [MediaItem],
        analyses: [PhotoAnalysisResult],
        exactDuplicateIDs: Set<String>
    ) -> Set<CandidatePair> {
        
        let validAnalyses = analyses.filter { !exactDuplicateIDs.contains($0.localIdentifier) }
        let validIDs = Set(validAnalyses.map { $0.localIdentifier })
        let validItems = items.filter { validIDs.contains($0.id) }
        
        diagnostics.totalAnalyzed = validAnalyses.count
        
        var candidatePairs = [CandidatePair: CandidatePair]()
        
        _ = Dictionary(uniqueKeysWithValues: validAnalyses.map { ($0.localIdentifier, $0) })
        
        // 1. Path A: Temporal & Burst
        let sortedItems = validItems.sorted { ($0.creationDate ?? .distantPast) < ($1.creationDate ?? .distantPast) }
        
        for i in 0..<sortedItems.count {
            let itemA = sortedItems[i]
            for j in (i+1)..<sortedItems.count {
                let itemB = sortedItems[j]
                
                if let dateA = itemA.creationDate, let dateB = itemB.creationDate {
                    let delta = abs(dateA.timeIntervalSince(dateB))
                    if delta <= SimilarityConfiguration.shared.closeTemporalProximity {
                        let newPair = CandidatePair(id1: itemA.id, id2: itemB.id, reason: .temporal)
                        if var existing = candidatePairs[newPair] {
                            existing.reasons.insert(.temporal)
                            candidatePairs[existing] = existing
                        } else {
                            candidatePairs[newPair] = newPair
                        }
                        diagnostics.temporalCandidates += 1
                        continue
                    } else if delta > SimilarityConfiguration.shared.sameDayTemporalProximity {
                        break
                    }
                }
            }
        }
        
        // 3. Path B: Visual (dHash via BK-Tree)
        var bkTree = BKTree()
        for analysis in validAnalyses {
            bkTree.insert(id: analysis.localIdentifier, hash: analysis.perceptualHash)
        }
        
        let threshold = SimilarityConfiguration.shared.dHashWeakThreshold
        for analysis in validAnalyses {
            let similarIDs = bkTree.search(hash: analysis.perceptualHash, maxDistance: threshold)
            for similarID in similarIDs {
                if similarID != analysis.localIdentifier {
                    let newPair = CandidatePair(id1: analysis.localIdentifier, id2: similarID, reason: .dHash)
                    if var existing = candidatePairs[newPair] {
                        existing.reasons.insert(.dHash)
                        candidatePairs[existing] = existing
                    } else {
                        candidatePairs[newPair] = newPair
                    }
                    diagnostics.dHashCandidates += 1
                }
            }
        }
        
        diagnostics.totalUniqueCandidates = candidatePairs.count
        let totalPossible = (validAnalyses.count * (validAnalyses.count - 1)) / 2
        if totalPossible > 0 {
            diagnostics.reductionRatio = Float(candidatePairs.count) / Float(totalPossible)
        }
        
        return Set(candidatePairs.values)
    }
}

nonisolated extension CandidatePair: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(firstID)
        hasher.combine(secondID)
    }
    public static func ==(lhs: CandidatePair, rhs: CandidatePair) -> Bool {
        return lhs.firstID == rhs.firstID && lhs.secondID == rhs.secondID
    }
}
