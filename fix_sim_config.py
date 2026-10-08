import re

with open("Gallery Cleaner/Services/Similarity/SimilarityConfiguration.swift", "r") as f:
    content = f.read()

content = content.replace("public struct SimilarityConfiguration {", "public struct SimilarityConfiguration: Sendable {\n    public nonisolated static let shared = SimilarityConfiguration()")
content = content.replace("    public static let shared = SimilarityConfiguration()\n", "")

with open("Gallery Cleaner/Services/Similarity/SimilarityConfiguration.swift", "w") as f:
    f.write(content)
