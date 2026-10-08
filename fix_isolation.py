import re

# CandidateGenerator.swift
with open("Gallery Cleaner/Services/Similarity/CandidateGenerator.swift", "r") as f:
    content = f.read()

content = content.replace("public func hash(into hasher: inout Hasher)", "nonisolated public func hash(into hasher: inout Hasher)")
content = content.replace("public static func ==(lhs: CandidatePair, rhs: CandidatePair)", "nonisolated public static func ==(lhs: CandidatePair, rhs: CandidatePair)")

with open("Gallery Cleaner/Services/Similarity/CandidateGenerator.swift", "w") as f:
    f.write(content)

# SimilarityScorer.swift
with open("Gallery Cleaner/Services/Similarity/SimilarityScorer.swift", "r") as f:
    content = f.read()

content = content.replace("mutating func record(distance: Float) {", "mutating public func record(distance: Float) {")

with open("Gallery Cleaner/Services/Similarity/SimilarityScorer.swift", "w") as f:
    f.write(content)

# PhotoRankingService.swift
with open("Gallery Cleaner/Services/Similarity/PhotoRankingService.swift", "r") as f:
    content = f.read()

content = content.replace("mutating func record(time: TimeInterval, topReasons: [QualityReason]) {", "mutating public func record(time: TimeInterval, topReasons: [QualityReason]) {")

with open("Gallery Cleaner/Services/Similarity/PhotoRankingService.swift", "w") as f:
    f.write(content)

