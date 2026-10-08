import re

with open("Gallery Cleaner/Services/Similarity/SimilarityScorer.swift", "r") as f:
    content = f.read()

# Remove the method from the struct
struct_method = """    mutating public func record(distance: Float) {
        scoredPairs += 1
        allDistances.append(distance)
        
        if distance < 1 { distanceBuckets["0-1", default: 0] += 1 }
        else if distance < 2 { distanceBuckets["1-2", default: 0] += 1 }
        else if distance < 3 { distanceBuckets["2-3", default: 0] += 1 }
        else if distance < 4 { distanceBuckets["3-4", default: 0] += 1 }
        else if distance < 5 { distanceBuckets["4-5", default: 0] += 1 }
        else if distance < 6 { distanceBuckets["5-6", default: 0] += 1 }
        else if distance < 8 { distanceBuckets["6-8", default: 0] += 1 }
        else if distance < 10 { distanceBuckets["8-10", default: 0] += 1 }
        else if distance < 12 { distanceBuckets["10-12", default: 0] += 1 }
        else if distance < 15 { distanceBuckets["12-15", default: 0] += 1 }
        else if distance < 20 { distanceBuckets["15-20", default: 0] += 1 }
        else { distanceBuckets["20+", default: 0] += 1 }
    }"""
content = content.replace(struct_method, "")

# Inline it in the actor where d.record is called
old_call = "d.record(distance: distance)"
new_call = """d.scoredPairs += 1
                    d.allDistances.append(distance)
                    if distance < 1 { d.distanceBuckets["0-1", default: 0] += 1 }
                    else if distance < 2 { d.distanceBuckets["1-2", default: 0] += 1 }
                    else if distance < 3 { d.distanceBuckets["2-3", default: 0] += 1 }
                    else if distance < 4 { d.distanceBuckets["3-4", default: 0] += 1 }
                    else if distance < 5 { d.distanceBuckets["4-5", default: 0] += 1 }
                    else if distance < 6 { d.distanceBuckets["5-6", default: 0] += 1 }
                    else if distance < 8 { d.distanceBuckets["6-8", default: 0] += 1 }
                    else if distance < 10 { d.distanceBuckets["8-10", default: 0] += 1 }
                    else if distance < 12 { d.distanceBuckets["10-12", default: 0] += 1 }
                    else if distance < 15 { d.distanceBuckets["12-15", default: 0] += 1 }
                    else if distance < 20 { d.distanceBuckets["15-20", default: 0] += 1 }
                    else { d.distanceBuckets["20+", default: 0] += 1 }"""
content = content.replace(old_call, new_call)

with open("Gallery Cleaner/Services/Similarity/SimilarityScorer.swift", "w") as f:
    f.write(content)

