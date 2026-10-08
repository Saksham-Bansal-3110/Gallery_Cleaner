import re

with open("Gallery Cleaner/Views/CategoryDetailView.swift", "r") as f:
    content = f.read()

old_sortedItems = """    var sortedItems: [MediaItem] {
        switch sortOption {
        case .defaultOrder: return rawItems
        case .newest: return rawItems.sorted { ($0.creationDate ?? Date.distantPast) > ($1.creationDate ?? Date.distantPast) }
        case .oldest: return rawItems.sorted { ($0.creationDate ?? Date.distantPast) < ($1.creationDate ?? Date.distantPast) }
        case .largest: return rawItems.sorted { $0.sizeInBytes > $1.sizeInBytes }
        case .smallest: return rawItems.sorted { $0.sizeInBytes < $1.sizeInBytes }
        }
    }"""

new_sortedItems = """    var sortedItems: [MediaItem] {
        switch sortOption {
        case .defaultOrder: return rawItems
        case .newest: 
            return rawItems.sorted { 
                let d1 = $0.creationDate ?? .distantPast
                let d2 = $1.creationDate ?? .distantPast
                if d1 == d2 { return $0.id > $1.id }
                return d1 > d2
            }
        case .oldest: 
            return rawItems.sorted { 
                let d1 = $0.creationDate ?? .distantPast
                let d2 = $1.creationDate ?? .distantPast
                if d1 == d2 { return $0.id < $1.id }
                return d1 < d2
            }
        case .largest: 
            return rawItems.sorted { 
                if $0.sizeInBytes == $1.sizeInBytes { return $0.id > $1.id }
                return $0.sizeInBytes > $1.sizeInBytes 
            }
        case .smallest: 
            return rawItems.sorted { 
                if $0.sizeInBytes == $1.sizeInBytes { return $0.id < $1.id }
                return $0.sizeInBytes < $1.sizeInBytes 
            }
        }
    }"""

old_sortedGroups = """    var sortedGroups: [DuplicateGroup] {
        switch sortOption {
        case .defaultOrder: return rawGroups
        case .newest:
            return rawGroups.sorted {
                let max1 = $0.items.compactMap { $0.creationDate }.max() ?? Date.distantPast
                let max2 = $1.items.compactMap { $0.creationDate }.max() ?? Date.distantPast
                return max1 > max2
            }
        case .oldest:
            return rawGroups.sorted {
                let min1 = $0.items.compactMap { $0.creationDate }.min() ?? Date.distantFuture
                let min2 = $1.items.compactMap { $0.creationDate }.min() ?? Date.distantFuture
                return min1 < min2
            }
        case .largest:
            return rawGroups.sorted {
                let size1 = $0.items.map { $0.sizeInBytes }.reduce(0, +)
                let size2 = $1.items.map { $0.sizeInBytes }.reduce(0, +)
                return size1 > size2
            }
        case .smallest:
            return rawGroups.sorted {
                let size1 = $0.items.map { $0.sizeInBytes }.reduce(0, +)
                let size2 = $1.items.map { $0.sizeInBytes }.reduce(0, +)
                return size1 < size2
            }
        }
    }"""

new_sortedGroups = """    var sortedGroups: [DuplicateGroup] {
        switch sortOption {
        case .defaultOrder: return rawGroups
        case .newest:
            return rawGroups.sorted {
                let max1 = $0.items.compactMap { $0.creationDate }.max() ?? .distantPast
                let max2 = $1.items.compactMap { $0.creationDate }.max() ?? .distantPast
                if max1 == max2 { return $0.id > $1.id }
                return max1 > max2
            }
        case .oldest:
            return rawGroups.sorted {
                let min1 = $0.items.compactMap { $0.creationDate }.min() ?? .distantPast
                let min2 = $1.items.compactMap { $0.creationDate }.min() ?? .distantPast
                if min1 == min2 { return $0.id < $1.id }
                return min1 < min2
            }
        case .largest:
            return rawGroups.sorted {
                let size1 = $0.items.map { $0.sizeInBytes }.reduce(0, +)
                let size2 = $1.items.map { $0.sizeInBytes }.reduce(0, +)
                if size1 == size2 { return $0.id > $1.id }
                return size1 > size2
            }
        case .smallest:
            return rawGroups.sorted {
                let size1 = $0.items.map { $0.sizeInBytes }.reduce(0, +)
                let size2 = $1.items.map { $0.sizeInBytes }.reduce(0, +)
                if size1 == size2 { return $0.id < $1.id }
                return size1 < size2
            }
        }
    }"""

content = content.replace(old_sortedItems, new_sortedItems)
content = content.replace(old_sortedGroups, new_sortedGroups)

with open("Gallery Cleaner/Views/CategoryDetailView.swift", "w") as f:
    f.write(content)

