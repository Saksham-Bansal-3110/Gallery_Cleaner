import re

with open("Gallery Cleaner/Views/CategoryDetailView.swift", "r") as f:
    content = f.read()

# Replace displayStyle and sortedDisplayStyle with rawItems, rawGroups, sortedItems, sortedGroups, activeDisplayStyle
old_properties = """    var displayStyle: CategoryDisplayStyle {
        switch categoryType {
        case .screenshots: return .grid(items: viewModel.screenshots)
        case .videos: return .grid(items: viewModel.videos)
        case .duplicatePhotos: return .grouped(groups: viewModel.duplicatePhotos)
        case .similarPhotos: return .grouped(groups: viewModel.similarPhotos)
        case .duplicateVideos: return .grouped(groups: viewModel.duplicateVideos)
        case .largeVideos: return .list(items: viewModel.largeVideos)
        }
    }
    
    var sortedDisplayStyle: CategoryDisplayStyle {
        switch displayStyle {
        case .grid(let items), .list(let items):
            let sortedItems: [MediaItem]
            switch sortOption {
            case .defaultOrder: sortedItems = items
            case .newest: sortedItems = items.sorted { ($0.creationDate ?? Date.distantPast) > ($1.creationDate ?? Date.distantPast) }
            case .oldest: sortedItems = items.sorted { ($0.creationDate ?? Date.distantPast) < ($1.creationDate ?? Date.distantPast) }
            case .largest: sortedItems = items.sorted { $0.sizeInBytes > $1.sizeInBytes }
            case .smallest: sortedItems = items.sorted { $0.sizeInBytes < $1.sizeInBytes }
            }
            if case .grid = displayStyle { return .grid(items: sortedItems) }
            else { return .list(items: sortedItems) }
            
        case .grouped(let groups):
            let sortedGroups: [DuplicateGroup]
            switch sortOption {
            case .defaultOrder: sortedGroups = groups
            case .newest:
                sortedGroups = groups.sorted {
                    let max1 = $0.items.compactMap { $0.creationDate }.max() ?? Date.distantPast
                    let max2 = $1.items.compactMap { $0.creationDate }.max() ?? Date.distantPast
                    return max1 > max2
                }
            case .oldest:
                sortedGroups = groups.sorted {
                    let min1 = $0.items.compactMap { $0.creationDate }.min() ?? Date.distantFuture
                    let min2 = $1.items.compactMap { $0.creationDate }.min() ?? Date.distantFuture
                    return min1 < min2
                }
            case .largest:
                sortedGroups = groups.sorted {
                    let size1 = $0.items.map { $0.sizeInBytes }.reduce(0, +)
                    let size2 = $1.items.map { $0.sizeInBytes }.reduce(0, +)
                    return size1 > size2
                }
            case .smallest:
                sortedGroups = groups.sorted {
                    let size1 = $0.items.map { $0.sizeInBytes }.reduce(0, +)
                    let size2 = $1.items.map { $0.sizeInBytes }.reduce(0, +)
                    return size1 < size2
                }
            }
            return .grouped(groups: sortedGroups)
        }
    }"""

new_properties = """    var rawItems: [MediaItem] {
        switch categoryType {
        case .screenshots: return viewModel.screenshots
        case .videos: return viewModel.videos
        case .largeVideos: return viewModel.largeVideos
        default: return []
        }
    }
    
    var rawGroups: [DuplicateGroup] {
        switch categoryType {
        case .duplicatePhotos: return viewModel.duplicatePhotos
        case .similarPhotos: return viewModel.similarPhotos
        case .duplicateVideos: return viewModel.duplicateVideos
        default: return []
        }
    }
    
    var sortedItems: [MediaItem] {
        switch sortOption {
        case .defaultOrder: return rawItems
        case .newest: return rawItems.sorted { ($0.creationDate ?? Date.distantPast) > ($1.creationDate ?? Date.distantPast) }
        case .oldest: return rawItems.sorted { ($0.creationDate ?? Date.distantPast) < ($1.creationDate ?? Date.distantPast) }
        case .largest: return rawItems.sorted { $0.sizeInBytes > $1.sizeInBytes }
        case .smallest: return rawItems.sorted { $0.sizeInBytes < $1.sizeInBytes }
        }
    }
    
    var sortedGroups: [DuplicateGroup] {
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
    }
    
    var activeDisplayStyle: CategoryDisplayStyle {
        switch categoryType {
        case .screenshots, .videos:
            return .grid(items: sortedItems)
        case .largeVideos:
            return .list(items: sortedItems)
        case .duplicatePhotos, .similarPhotos, .duplicateVideos:
            return .grouped(groups: sortedGroups)
        }
    }"""

content = content.replace(old_properties, new_properties)
content = content.replace("sortedDisplayStyle", "activeDisplayStyle")
content = content.replace("case .grouped(let groups) = displayStyle", "case .grouped(let groups) = activeDisplayStyle")

with open("Gallery Cleaner/Views/CategoryDetailView.swift", "w") as f:
    f.write(content)

