import re

with open("Gallery Cleaner/Services/Similarity/SimilarityConfiguration.swift", "r") as f:
    content = f.read()

content = content.replace("public var currentVisionRevision: Int {", "public nonisolated var currentVisionRevision: Int {")

with open("Gallery Cleaner/Services/Similarity/SimilarityConfiguration.swift", "w") as f:
    f.write(content)
