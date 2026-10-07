import Foundation

let path = "Gallery Cleaner/Services/Similarity/SimilarityScorer.swift"
var content = try! String(contentsOfFile: path)

let newStruct = """
public struct SimilarityScore: Sendable {
    public let firstID: String
    public let secondID: String
    public let distance: Float
    public let reasons: Set<CandidateReason>
}
"""

if let range = content.range(of: "public struct SimilarityScore: Sendable \\{[\\s\\S]*?\\}", options: .regularExpression) {
    content.replaceSubrange(range, with: newStruct)
}

let newDiag = """
public class SimilarityScorerDiagnostics {
    public var scoredPairs: Int = 0
    public var allDistances: [Float] = []
    public var distanceBuckets: [String: Int] = [
        "0-1": 0, "1-2": 0, "2-3": 0, "3-4": 0,
        "4-5": 0, "5-6": 0, "6-8": 0, "8-10": 0,
        "10-12": 0, "12-15": 0, "15-20": 0, "20+": 0
    ]
    
    public init() {}
    
    func record(distance: Float) {
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
"""

if let range = content.range(of: "public class SimilarityScorerDiagnostics \\{[\\s\\S]*?\\}", options: .regularExpression) {
    content.replaceSubrange(range, with: newDiag)
}

content = content.replacingOccurrences(of: """
scores.append(SimilarityScore(firstID: pair.firstID, secondID: pair.secondID, distance: distance))
""", with: """
scores.append(SimilarityScore(firstID: pair.firstID, secondID: pair.secondID, distance: distance, reasons: pair.reasons))
""")

content = content.replacingOccurrences(of: "diagnostics.minDistance", with: "diagnostics.allDistances.min() ?? 0")
content = content.replacingOccurrences(of: "diagnostics.maxDistance", with: "diagnostics.allDistances.max() ?? 0")
content = content.replacingOccurrences(of: "diagnostics.totalDistance / Float(diagnostics.scoredPairs)", with: "diagnostics.allDistances.reduce(0, +) / Float(max(1, diagnostics.allDistances.count))")
content = content.replacingOccurrences(of: "[\"0-2\", \"2-4\", \"4-6\", \"6-8\", \"8-10\", \"10-12\", \"12-15\", \"15+\"]", with: "[\"0-1\", \"1-2\", \"2-3\", \"3-4\", \"4-5\", \"5-6\", \"6-8\", \"8-10\", \"10-12\", \"12-15\", \"15-20\", \"20+\"]")

try! content.write(toFile: path, atomically: true, encoding: .utf8)
