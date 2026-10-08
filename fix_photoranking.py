import re

with open("Gallery Cleaner/Services/Similarity/PhotoRankingService.swift", "r") as f:
    content = f.read()

content = content.replace("    public init() {}\n    \n    mutating func record(time: TimeInterval, topReasons: [QualityReason]) {", "    nonisolated public init() {}\n    \n    mutating func record(time: TimeInterval, topReasons: [QualityReason]) {")

with open("Gallery Cleaner/Services/Similarity/PhotoRankingService.swift", "w") as f:
    f.write(content)
