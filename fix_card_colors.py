import re
import os

files_to_fix = [
    "Gallery Cleaner/Components/CategoryCard.swift",
    "Gallery Cleaner/Components/DuplicateGroupView.swift",
    "Gallery Cleaner/Components/StorageDonutChart.swift",
    "Gallery Cleaner/Views/CategoryDetailView.swift",
    "Gallery Cleaner/Views/HomeView.swift"
]

for file_path in files_to_fix:
    if os.path.exists(file_path):
        with open(file_path, "r") as f:
            content = f.read()
        
        content = content.replace("Color(.secondarySystemGroupedBackground)", "Color(.secondarySystemBackground)")
        
        with open(file_path, "w") as f:
            f.write(content)

