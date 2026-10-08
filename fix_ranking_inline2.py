import re

with open("Gallery Cleaner/Services/Similarity/PhotoRankingService.swift", "r") as f:
    content = f.read()

content = content.replace("diagnostics.record(time: elapsed, topReasons: topReasons)", """diagnostics.groupsRanked += 1
        diagnostics.totalRankingTime += elapsed
        for r in topReasons {
            diagnostics.recommendationReasons[r, default: 0] += 1
        }""")

with open("Gallery Cleaner/Services/Similarity/PhotoRankingService.swift", "w") as f:
    f.write(content)

