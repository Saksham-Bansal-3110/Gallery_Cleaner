import re

# Update AssetAnalysisData.swift
with open("Gallery Cleaner/Services/Similarity/AssetAnalysisData.swift", "r") as f:
    content = f.read()

content = content.replace("public struct PhotoAnalysisResult {", "public struct PhotoAnalysisResult: Sendable {")

with open("Gallery Cleaner/Services/Similarity/AssetAnalysisData.swift", "w") as f:
    f.write(content)

# Update PhotoAnalysisCache.swift
with open("Gallery Cleaner/Services/Similarity/PhotoAnalysisCache.swift", "r") as f:
    content = f.read()

content = content.replace("extension PhotoAnalysisResult: Sendable {}\n\n", "")

with open("Gallery Cleaner/Services/Similarity/PhotoAnalysisCache.swift", "w") as f:
    f.write(content)

