import Foundation

let path = "Gallery Cleaner/Views/CategoryDetailView.swift"
var content = try! String(contentsOfFile: path)

// 1. We remove the ZStack bottom overlay for isSelectionMode
if let range = content.range(of: """
            if isSelectionMode {
                VStack {
                    Spacer()
                    SelectionToolbar(onSelectAll: {
                        let targetIDs: Set<String>
                        if case .grouped(let groups) = displayStyle, categoryType != .similarPhotos {
                            let safeIDs = groups.flatMap { $0.items.dropFirst() }.map { $0.id }
                            targetIDs = Set(safeIDs)
                        } else {
                            targetIDs = allItemIDs
                        }
                        
                        if selectedItems == targetIDs || selectedItems.count == allItemIDs.count {
                            selectedItems.removeAll()
                        } else {
                            selectedItems = targetIDs
                        }
                    }, onDelete: {
                        if !selectedItems.isEmpty {
                            showDeleteConfirmation = true
                        }
                    })
                    .disabled(isDeleting)
                }
            }
""") {
    content.removeSubrange(range)
}

// 2. Insert safeAreaInset on ScrollView
let target = """
                        }
                    }
                }
            }
"""
let replacement = """
                        }
                    }
                    .safeAreaInset(edge: .bottom) {
                        if isSelectionMode {
                            VStack(spacing: 8) {
                                Text("\(selectedItems.count) Selected • \\(viewModel.formatSize(viewModel.totalSize(for: selectedMediaItems)))")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.top, 12)
                                
                                SelectionToolbar(onSelectAll: {
                                    let targetIDs: Set<String>
                                    if case .grouped(let groups) = displayStyle, categoryType != .similarPhotos {
                                        let safeIDs = groups.flatMap { $0.items.dropFirst() }.map { $0.id }
                                        targetIDs = Set(safeIDs)
                                    } else {
                                        targetIDs = allItemIDs
                                    }
                                    
                                    if selectedItems == targetIDs || selectedItems.count == allItemIDs.count {
                                        selectedItems.removeAll()
                                    } else {
                                        selectedItems = targetIDs
                                    }
                                }, onDelete: {
                                    if !selectedItems.isEmpty {
                                        showDeleteConfirmation = true
                                    }
                                })
                                .disabled(isDeleting)
                            }
                            .background(Color.black.opacity(0.95))
                        }
                    }
                }
            }
"""
content = content.replacingOccurrences(of: target, with: replacement)

// 3. Change itemsCountText at top to only show total info, not selection info.
let topTextTarget = """
    var itemsCountText: String {
        if isSelectionMode && !selectedItems.isEmpty {
            let size = viewModel.totalSize(for: selectedMediaItems)
            return "\\(selectedItems.count) Selected • \\(viewModel.formatSize(size))"
        } else {
            let size = viewModel.totalSize(for: Array(Set(allItemsList)))
            return "\\(itemsCount) Items • \\(viewModel.formatSize(size))"
        }
    }
"""
let topTextReplacement = """
    var itemsCountText: String {
        let size = viewModel.totalSize(for: Array(Set(allItemsList)))
        return "\\(itemsCount) Items • \\(viewModel.formatSize(size))"
    }
"""
content = content.replacingOccurrences(of: topTextTarget, with: topTextReplacement)

try! content.write(toFile: path, atomically: true, encoding: .utf8)

