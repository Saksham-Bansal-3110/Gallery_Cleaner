import Foundation
import Vision

public struct SimilarityScore: Sendable {
    public let firstID: String
    public let secondID: String
    public let distance: Float
    public let reasons: Set<CandidateReason>
}

public struct SimilarityScorerDiagnostics: Sendable {
    public var scoredPairs: Int = 0
    public var allDistances: [Float] = []
    public var distanceBuckets: [String: Int] = [
        "0-1": 0, "1-2": 0, "2-3": 0, "3-4": 0,
        "4-5": 0, "5-6": 0, "6-8": 0, "8-10": 0,
        "10-12": 0, "12-15": 0, "15-20": 0, "20+": 0
    ]
    
    public init() {}
    
    mutating func record(distance: Float) {
        scoredPairs += 1
        allDistances.append(distance)
        
        if distance < 1 { distanceBuckets["0-1", default: 0] += 1 }
        else if distance < 2 { distanceBuckets["1-2", default: 0] += 1 }
        else if distance < 3 { distanceBuckets["2-3", default: 0] += 1 }
        else if distance < 4 { distanceBuckets["3-4", default: 0] += 1 }
        else if distance < 5 { distanceBuckets["4-5", default: 0] += 1 }
        else if distance < 6 { distanceBuckets["5-6", default: 0] += 1 }
        else if distance < 8 { distanceBuckets["6-8", default: 0] += 1 }
        else if distance < 10 { distanceBuckets["8-10", default: 0] += 1 }
        else if distance < 12 { distanceBuckets["10-12", default: 0] += 1 }
        else if distance < 15 { distanceBuckets["12-15", default: 0] += 1 }
        else if distance < 20 { distanceBuckets["15-20", default: 0] += 1 }
        else { distanceBuckets["20+", default: 0] += 1 }
    }
    
    public func percentile(_ p: Float) -> Float {
        guard !allDistances.isEmpty else { return 0 }
        let sorted = allDistances.sorted()
        let index = Int(Float(sorted.count - 1) * p)
        return sorted[index]
    }
}

public actor SimilarityScorer {
    public var diagnostics = SimilarityScorerDiagnostics()
    
    public init() {}
    
    public func score(pairs: Set<CandidatePair>, analyses: [PhotoAnalysisResult]) async -> [SimilarityScore] {
        let analysisDict = Dictionary(uniqueKeysWithValues: analyses.map { ($0.localIdentifier, $0) })
        
        var scores = [SimilarityScore]()
        
        for pair in pairs {
            guard let a1 = analysisDict[pair.firstID], let a2 = analysisDict[pair.secondID] else { continue }
            
            do {
                guard let obs1 = try NSKeyedUnarchiver.unarchivedObject(ofClass: VNFeaturePrintObservation.self, from: a1.visionFeatureData) else { continue }
                guard let obs2 = try NSKeyedUnarchiver.unarchivedObject(ofClass: VNFeaturePrintObservation.self, from: a2.visionFeatureData) else { continue }
                
                var distance: Float = 0
                try obs1.computeDistance(&distance, to: obs2)
                
                if distance > 0.05 {
                    scores.append(SimilarityScore(firstID: pair.firstID, secondID: pair.secondID, distance: distance, reasons: pair.reasons))
                    var d = diagnostics
d.record(distance: distance)
diagnostics = d
                }
            } catch {
                print("SimilarityScorer: Failed to compute distance for pair \\(pair.firstID) & \\(pair.secondID)")
            }
        }
        
        return scores
    }
}
