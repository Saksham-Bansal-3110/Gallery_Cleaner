import re

with open("Gallery Cleaner/Components/DuplicateGroupView.swift", "r") as f:
    content = f.read()

old_scroll = """            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(group.items) { item in
                        Group {
                            if isSelectionMode {
                                Button(action: {
                                    if selectedItems.contains(item.id) { selectedItems.remove(item.id) }
                                    else { selectedItems.insert(item.id) }
                                }) {
                                    MediaThumbnail(
                                        item: item,
                                        isSelected: selectedItems.contains(item.id),
                                        isSelectionMode: isSelectionMode,
                                        isRecommended: group.recommendedItem?.id == item.id,
                                        onTap: {}
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            } else {
                                NavigationLink(value: item) {
                                    MediaThumbnail(
                                        item: item,
                                        isSelected: false,
                                        isSelectionMode: false,
                                        isRecommended: group.recommendedItem?.id == item.id,
                                        onTap: {}
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .frame(width: 120, height: 120)
                    }
                }
            }"""

new_grid = """            let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(group.items) { item in
                    Group {
                        if isSelectionMode {
                            Button(action: {
                                if selectedItems.contains(item.id) { selectedItems.remove(item.id) }
                                else { selectedItems.insert(item.id) }
                            }) {
                                MediaThumbnail(
                                    item: item,
                                    isSelected: selectedItems.contains(item.id),
                                    isSelectionMode: isSelectionMode,
                                    isRecommended: group.recommendedItem?.id == item.id,
                                    onTap: {}
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        } else {
                            NavigationLink(value: item) {
                                MediaThumbnail(
                                    item: item,
                                    isSelected: false,
                                    isSelectionMode: false,
                                    isRecommended: group.recommendedItem?.id == item.id,
                                    onTap: {}
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .aspectRatio(1, contentMode: .fit)
                }
            }"""

content = content.replace(old_scroll, new_grid)

with open("Gallery Cleaner/Components/DuplicateGroupView.swift", "w") as f:
    f.write(content)

