with open("Gallery Cleaner/App/GalleryCleanerApp.swift", "r") as f:
    content = f.read()

content = content.replace("await SimilarityTests.runAll()", "await SimilarityTests.runAll()\n                    CategorySortTests.runAll()")

with open("Gallery Cleaner/App/GalleryCleanerApp.swift", "w") as f:
    f.write(content)

