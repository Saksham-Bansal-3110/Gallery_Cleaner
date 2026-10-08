import re

with open("Gallery Cleaner/Services/SimilarPhotoScanner.swift", "r") as f:
    content = f.read()

content = content.replace('var title = "Similar \\\\(index + 1)"', 'var title = "Similar \\(index + 1)"')

with open("Gallery Cleaner/Services/SimilarPhotoScanner.swift", "w") as f:
    f.write(content)
