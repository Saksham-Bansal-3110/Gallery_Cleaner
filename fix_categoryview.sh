#!/bin/bash

# We will use sed to inject allItemsList, selectedMediaItems, and itemsCountText.

cat << 'INNER_EOF' > inject_properties.swift
    var allItemsList: [MediaItem] {
        switch displayStyle {
        case .grid(let items), .list(let items):
            return items
        case .grouped(let groups):
            return groups.flatMap { $0.items }
        }
    }
    
    var selectedMediaItems: [MediaItem] {
        let uniqueItems = Set(allItemsList)
        return Array(uniqueItems.filter { selectedItems.contains($0.id) })
    }
    
    var itemsCountText: String {
        if isSelectionMode && !selectedItems.isEmpty {
            let size = viewModel.totalSize(for: selectedMediaItems)
            return "\(selectedItems.count) Selected • \(viewModel.formatSize(size))"
        } else {
            let size = viewModel.totalSize(for: Array(Set(allItemsList)))
            return "\(itemsCount) Items • \(viewModel.formatSize(size))"
        }
    }
INNER_EOF

# Replace "var itemsCount: Int" with the properties.
sed -i '' -e '/var itemsCount: Int {/,/}/ {
    r inject_properties.swift
    d
}' "Gallery Cleaner/Views/CategoryDetailView.swift"

# Now we need to re-add var itemsCount: Int since it was deleted
sed -i '' -e 's/var allItemsList: \[MediaItem\] {/var itemsCount: Int {\n        allItemIDs.count\n    }\n\n    var allItemsList: [MediaItem] {/' "Gallery Cleaner/Views/CategoryDetailView.swift"

# Replace Text("\(itemsCount) Items • \(totalSize)") with Text(itemsCountText)
sed -i '' -e 's/Text("\(itemsCount) Items • \(totalSize)")/Text(itemsCountText)/' "Gallery Cleaner/Views/CategoryDetailView.swift"

# Delete var totalSize property since we no longer use it
sed -i '' -e '/var totalSize: String {/,/}/d' "Gallery Cleaner/Views/CategoryDetailView.swift"

