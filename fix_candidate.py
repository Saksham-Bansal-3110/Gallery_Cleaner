import re

with open("Gallery Cleaner/Services/Similarity/CandidateGenerator.swift", "r") as f:
    content = f.read()

content = content.replace("let analysisDict = Dictionary", "_ = Dictionary")

with open("Gallery Cleaner/Services/Similarity/CandidateGenerator.swift", "w") as f:
    f.write(content)
