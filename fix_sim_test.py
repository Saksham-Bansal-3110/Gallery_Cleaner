import re

with open("Gallery Cleaner/Services/Similarity/SimilarityTests.swift", "r") as f:
    content = f.read()

content = content.replace('let id1 = "A\\\\(idx)"', 'let id1 = "A\\(idx)"')
content = content.replace('let id2 = "B\\\\(idx)"', 'let id2 = "B\\(idx)"')

with open("Gallery Cleaner/Services/Similarity/SimilarityTests.swift", "w") as f:
    f.write(content)
