import re

with open("Gallery Cleaner/Services/Similarity/SimilarityScorer.swift", "r") as f:
    content = f.read()

content = content.replace("    public init() {}\n    \n    mutating func record(distance: Float) {", "    nonisolated public init() {}\n    \n    mutating func record(distance: Float) {")

with open("Gallery Cleaner/Services/Similarity/SimilarityScorer.swift", "w") as f:
    f.write(content)
