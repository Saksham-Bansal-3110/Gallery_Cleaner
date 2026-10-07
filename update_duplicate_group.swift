import Foundation

let path = "Gallery Cleaner/Components/DuplicateGroupView.swift"
var content = try! String(contentsOfFile: path)
content = content.replacingOccurrences(of: """
                            MediaThumbnail(
                                item: item,
                                isSelected: selectedItems.contains(item.id),
                                isSelectionMode: isSelectionMode,
                                onTap: {
""", with: """
                            MediaThumbnail(
                                item: item,
                                isSelected: selectedItems.contains(item.id),
                                isSelectionMode: isSelectionMode,
                                isRecommended: group.recommendedItem?.id == item.id,
                                onTap: {
""")
try! content.write(toFile: path, atomically: true, encoding: .utf8)
