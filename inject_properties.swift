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
