import re

# SimilarityScorer.swift
with open("Gallery Cleaner/Services/Similarity/SimilarityScorer.swift", "r") as f:
    content = f.read()

content = content.replace("mutating public func record(distance: Float) {", "mutating public func record(distance: Float) {")
content = content.replace("public struct SimilarityScorerDiagnostics: Sendable {", "@preconcurrency public struct SimilarityScorerDiagnostics: Sendable {")

with open("Gallery Cleaner/Services/Similarity/SimilarityScorer.swift", "w") as f:
    f.write(content)


# PhotoRankingService.swift
with open("Gallery Cleaner/Services/Similarity/PhotoRankingService.swift", "r") as f:
    content = f.read()

content = content.replace("public struct PhotoRankingDiagnostics: Sendable {", "@preconcurrency public struct PhotoRankingDiagnostics: Sendable {")

with open("Gallery Cleaner/Services/Similarity/PhotoRankingService.swift", "w") as f:
    f.write(content)

