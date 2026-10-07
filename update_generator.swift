import Foundation

let path = "Gallery Cleaner/Services/Similarity/CandidateGenerator.swift"
var content = try! String(contentsOfFile: path)

// Define CandidateReason
let newStructs = """
public enum CandidateReason: String, Hashable, Sendable, CustomStringConvertible {
    case temporal
    case burst
    case dHash
    
    public var description: String { return self.rawValue }
}

public struct CandidatePair: Hashable, Sendable {
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
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(firstID)
        hasher.combine(secondID)
    }
    
    public static func ==(lhs: CandidatePair, rhs: CandidatePair) -> Bool {
        return lhs.firstID == rhs.firstID && lhs.secondID == rhs.secondID
    }
}
"""
// Replace the old CandidatePair
if let range = content.range(of: "public struct CandidatePair: Hashable, Sendable \\{[\\s\\S]*?\\}", options: .regularExpression) {
    content.replaceSubrange(range, with: newStructs)
} else if let range = content.range(of: "public struct CandidatePair: Hashable \\{[\\s\\S]*?\\}", options: .regularExpression) {
    content.replaceSubrange(range, with: newStructs)
}

// Replace Set<CandidatePair> operations
content = content.replacingOccurrences(of: "var candidatePairs = Set<CandidatePair>()", with: "var candidatePairs = [CandidatePair: CandidatePair]()")

content = content.replacingOccurrences(of: "candidatePairs.insert(CandidatePair(id1: itemA.id, id2: itemB.id))", with: """
                        let newPair = CandidatePair(id1: itemA.id, id2: itemB.id, reason: .temporal)
                        if var existing = candidatePairs[newPair] {
                            existing.reasons.insert(.temporal)
                            candidatePairs[existing] = existing
                        } else {
                            candidatePairs[newPair] = newPair
                        }
""")
content = content.replacingOccurrences(of: "candidatePairs.insert(CandidatePair(id1: analysis.localIdentifier, id2: similarID))", with: """
                    let newPair = CandidatePair(id1: analysis.localIdentifier, id2: similarID, reason: .dHash)
                    if var existing = candidatePairs[newPair] {
                        existing.reasons.insert(.dHash)
                        candidatePairs[existing] = existing
                    } else {
                        candidatePairs[newPair] = newPair
                    }
""")
content = content.replacingOccurrences(of: "return candidatePairs", with: "return Set(candidatePairs.values)")
content = content.replacingOccurrences(of: "-> Set<CandidatePair> {", with: "-> Set<CandidatePair> {")

try! content.write(toFile: path, atomically: true, encoding: .utf8)
