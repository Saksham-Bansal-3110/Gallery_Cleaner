import re

# CandidateGenerator.swift
with open("Gallery Cleaner/Services/Similarity/CandidateGenerator.swift", "r") as f:
    content = f.read()

content = content.replace("public struct CandidatePair: Hashable, Sendable {", "public struct CandidatePair: Sendable {")
content = content.replace("    nonisolated public func hash(into hasher: inout Hasher) {\n        hasher.combine(firstID)\n        hasher.combine(secondID)\n    }\n    \n    nonisolated public static func ==(lhs: CandidatePair, rhs: CandidatePair) -> Bool {\n        return lhs.firstID == rhs.firstID && lhs.secondID == rhs.secondID\n    }\n", "")
content += """
nonisolated extension CandidatePair: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(firstID)
        hasher.combine(secondID)
    }
    public static func ==(lhs: CandidatePair, rhs: CandidatePair) -> Bool {
        return lhs.firstID == rhs.firstID && lhs.secondID == rhs.secondID
    }
}
"""

with open("Gallery Cleaner/Services/Similarity/CandidateGenerator.swift", "w") as f:
    f.write(content)

