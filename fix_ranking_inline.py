import re

with open("Gallery Cleaner/Services/Similarity/PhotoRankingService.swift", "r") as f:
    content = f.read()

# Remove the method from the struct
struct_method = """    mutating public func record(time: TimeInterval, topReasons: [QualityReason]) {
        groupsRanked += 1
        totalRankingTime += time
        for r in topReasons {
            recommendationReasons[r, default: 0] += 1
        }
    }"""
content = content.replace(struct_method, "")

# Inline it in the actor where d.record is called
old_call = "d.record(time: duration, topReasons: bestReasons)"
new_call = """d.groupsRanked += 1
        d.totalRankingTime += duration
        for r in bestReasons {
            d.recommendationReasons[r, default: 0] += 1
        }"""
content = content.replace(old_call, new_call)

with open("Gallery Cleaner/Services/Similarity/PhotoRankingService.swift", "w") as f:
    f.write(content)

