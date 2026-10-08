import os

def fix_file(filepath, return_statement):
    with open(filepath, 'r') as f:
        content = f.read()
    
    new_return = f"""        let sortedGroups = {return_statement.replace('return ', '')}
        return sortedGroups.enumerated().map {{ index, group in
            DuplicateGroup(
                id: group.id,
                title: "Group \\(index + 1)",
                items: group.items,
                recommendedItem: group.recommendedItem,
                rankedItems: group.rankedItems
            )
        }}"""
    
    content = content.replace(return_statement, new_return)
    with open(filepath, 'w') as f:
        f.write(content)

fix_file("Gallery Cleaner/Services/DuplicatePhotoScanner.swift", "return duplicateGroups.sorted { ($0.items.first?.creationDate ?? Date.distantPast) > ($1.items.first?.creationDate ?? Date.distantPast) }")
fix_file("Gallery Cleaner/Services/DuplicateVideoScanner.swift", "return duplicateGroups.sorted { ($0.items.first?.creationDate ?? Date.distantPast) > ($1.items.first?.creationDate ?? Date.distantPast) }")
fix_file("Gallery Cleaner/Services/SimilarPhotoScanner.swift", "return similarGroups")
