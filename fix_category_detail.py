import re

with open("Gallery Cleaner/Views/CategoryDetailView.swift", "r") as f:
    content = f.read()

# Add states
states_insertion = """    @State private var selectedItems: Set<String> = []
    @State private var sortOption: MediaSortOption = .defaultOrder
    @State private var showSortSheet = false"""
content = content.replace("    @State private var selectedItems: Set<String> = []", states_insertion)

# Add sortedDisplayStyle computed property
displayStyle_end = """        case .largeVideos: return .list(items: viewModel.largeVideos)
        }
    }"""
sortedDisplayStyle = """        case .largeVideos: return .list(items: viewModel.largeVideos)
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
content = content.replace(displayStyle_end, sortedDisplayStyle)

# Replace displayStyle switch in body
content = content.replace("switch displayStyle {", "switch sortedDisplayStyle {")

# Add sort toolbar item
toolbar_code = """        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if isSelectionMode {"""
new_toolbar = """        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if !isSelectionMode && itemsCount > 0 {
                    Button(action: { showSortSheet = true }) {
                        Image(systemName: sortOption == .defaultOrder ? "arrow.up.arrow.down.circle" : "arrow.up.arrow.down.circle.fill")
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if isSelectionMode {"""
content = content.replace(toolbar_code, new_toolbar)

# Add sheet
sheet_code = """        .navigationDestination(for: MediaItem.self) { item in
            MediaDetailView(item: item)
        }
    }"""
new_sheet_code = """        .navigationDestination(for: MediaItem.self) { item in
            MediaDetailView(item: item)
        }
        .sheet(isPresented: $showSortSheet) {
            MediaSortSheet(sortOption: $sortOption)
                .presentationDetents([.medium])
        }
    }"""
content = content.replace(sheet_code, new_sheet_code)

with open("Gallery Cleaner/Views/CategoryDetailView.swift", "w") as f:
    f.write(content)

