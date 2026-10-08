//
//  CategoryDetailView.swift
//  Gallery Cleaner
//

import SwiftUI

struct CategoryDetailView: View {
    var title: String
    var categoryType: CategoryType
    
    @EnvironmentObject var viewModel: GalleryViewModel
    @Environment(\.dismiss) var dismiss
    @State private var isSelectionMode = false
    @State private var selectedItems: Set<String> = []
    @State private var sortOption: MediaSortOption = .defaultOrder
    @State private var showSortSheet = false
    
    var rawItems: [MediaItem] {
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
    }
    
    var sortedGroups: [DuplicateGroup] {
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
    }
    
    let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]
    
    var allItemIDs: Set<String> {
        switch activeDisplayStyle {
        case .grid(let items), .list(let items):
            return Set(items.map { $0.id })
        case .grouped(let groups):
            return Set(groups.flatMap { $0.items }.map { $0.id })
        }
    }
    
    var allItemsList: [MediaItem] {
        switch activeDisplayStyle {
        case .grid(let items), .list(let items):
            return items
        case .grouped(let groups):
            return groups.flatMap { $0.items }
        }
    }
    
    var itemsCount: Int {
        allItemIDs.count
    }
    
    var selectedMediaItems: [MediaItem] {
        let uniqueItems = Set(allItemsList)
        return Array(uniqueItems.filter { selectedItems.contains($0.id) })
    }
    
    var itemsCountText: String {
        let size = viewModel.totalSize(for: Array(Set(allItemsList)))
        return "\(itemsCount) Items • \(viewModel.formatSize(size))"
    }
    
    @State private var showDeleteConfirmation = false
    @State private var deleteError: String? = nil
    @State private var isDeleting = false
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            VStack(spacing: 0) {
                if itemsCount == 0 {
                    Spacer()
                    Text("No Items")
                        .foregroundStyle(.secondary)
                    Spacer()
                } else {
                    ScrollView {
                        VStack {
                            Text(itemsCountText)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .padding(.vertical, 8)
                        }
                        switch activeDisplayStyle {
                        case .grid(let items):
                            LazyVGrid(columns: columns, spacing: 8) {
                                ForEach(items) { item in
                                    Group {
                                        if isSelectionMode {
                                            Button(action: {
                                                if !isDeleting {
                                                    if selectedItems.contains(item.id) { selectedItems.remove(item.id) }
                                                    else { selectedItems.insert(item.id) }
                                                }
                                            }) {
                                                MediaThumbnail(item: item, isSelected: selectedItems.contains(item.id), isSelectionMode: isSelectionMode, onTap: {})
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        } else {
                                            NavigationLink(value: item) {
                                                MediaThumbnail(item: item, isSelected: false, isSelectionMode: false, onTap: {})
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                    .aspectRatio(1, contentMode: .fit)
                                    .opacity(isDeleting ? 0.5 : 1.0)
                                    .animation(.default, value: isDeleting)
                                }
                            }
                            .padding(.horizontal, 16)
                            
                            
                        case .list(let items):
                            LazyVStack(spacing: 12) {
                                ForEach(items) { item in
                                    HStack(spacing: 12) {
                                        if isSelectionMode {
                                            Button(action: {
                                                if selectedItems.contains(item.id) {
                                                    selectedItems.remove(item.id)
                                                } else {
                                                    selectedItems.insert(item.id)
                                                }
                                            }) {
                                                Image(systemName: selectedItems.contains(item.id) ? "checkmark.circle.fill" : "circle")
                                                    .font(.system(size: 20))
                                                    .foregroundStyle(selectedItems.contains(item.id) ? .blue : .primary)
                                                    .background(
                                                        Circle()
                                                            .fill(selectedItems.contains(item.id) ? Color(.systemBackground) : Color.clear)
                                                            .frame(width: 18, height: 18)
                                                    )
                                            }
                                            .disabled(isDeleting)
                                        }
                                        
                                        Group {
                                            if isSelectionMode {
                                                MediaThumbnail(item: item, isSelected: false, isSelectionMode: false) { }
                                            } else {
                                                NavigationLink(value: item) {
                                                    MediaThumbnail(item: item, isSelected: false, isSelectionMode: false) { }
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                            }
                                        }
                                        .frame(width: 80, height: 80)
                                        .cornerRadius(8)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(item.filename ?? "Unknown")
                                                .font(.body.weight(.medium))
                                                .foregroundStyle(.primary)
                                                .lineLimit(1)
                                            
                                            HStack(spacing: 8) {
                                                Text(item.formattedSize)
                                                    .font(.subheadline)
                                                    .foregroundStyle(.secondary)
                                                
                                                if let duration = item.formattedDuration {
                                                    Text("•")
                                                        .foregroundStyle(Color(.tertiaryLabel))
                                                    Text(duration)
                                                        .font(.subheadline)
                                                        .foregroundStyle(.secondary)
                                                }
                                            }
                                        }
                                        Spacer()
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(Color(.secondarySystemGroupedBackground))
                                    .cornerRadius(12)
                                    .padding(.horizontal, 16)
                                    .opacity(isDeleting ? 0.5 : 1.0)
                                    .animation(.default, value: isDeleting)
                                }
                            }
                            
                            
                        case .grouped(let groups):
                            LazyVStack(spacing: 16) {
                                ForEach(groups) { group in
                                    DuplicateGroupView(
                                        group: group,
                                        selectedItems: $selectedItems,
                                        isSelectionMode: isSelectionMode
                                    )
                                    .opacity(isDeleting ? 0.5 : 1.0)
                                    .animation(.default, value: isDeleting)
                                    .disabled(isDeleting)
                                }
                            }
                            .padding(.horizontal, 16)
                            
                        }
                    }
                    .safeAreaInset(edge: .bottom) {
                        if isSelectionMode {
                            VStack(spacing: 8) {
                                Text("\(selectedItems.count) Selected • \(viewModel.formatSize(viewModel.totalSize(for: selectedMediaItems)))")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.primary)
                                    .padding(.top, 12)
                                
                                SelectionToolbar(onSelectAll: {
                                    let targetIDs: Set<String>
                                    if case .grouped(let groups) = activeDisplayStyle, categoryType != .similarPhotos {
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
                            .background(Color(.systemBackground).opacity(0.95))
                        }
                    }
                }
            }

            
            if isDeleting {
                Color(.systemBackground).opacity(0.4).ignoresSafeArea()
                ProgressView("Deleting & Refreshing...")
                    .foregroundStyle(.primary)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .padding(24)
                    .background(Color(.tertiarySystemFill))
                    .cornerRadius(16)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if !isSelectionMode && itemsCount > 0 {
                    Button(action: { showSortSheet = true }) {
                        Image(systemName: sortOption == .defaultOrder ? "arrow.up.arrow.down.circle" : "arrow.up.arrow.down.circle.fill")
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if isSelectionMode {
                    Button("Cancel") {
                        isSelectionMode = false
                        selectedItems.removeAll()
                    }
                    .disabled(isDeleting)
                } else {
                    Button("Select") {
                        isSelectionMode = true
                        if case .grouped(let groups) = activeDisplayStyle, categoryType != .similarPhotos {
                            for group in groups {
                                let itemsToSelect = group.items.dropFirst()
                                for item in itemsToSelect {
                                    selectedItems.insert(item.id)
                                }
                            }
                        }
                    }
                    .disabled(itemsCount == 0)
                }
            }
        }
        .confirmationDialog(
            "Delete \(selectedItems.count) item(s)?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                deleteSelectedItems()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("These items will be permanently deleted from your Photo Library.")
        }
        .alert("Error", isPresented: Binding(get: { deleteError != nil }, set: { if !$0 { deleteError = nil } })) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(deleteError ?? "")
        }
        .navigationDestination(for: MediaItem.self) { item in
            MediaDetailView(item: item)
        }
        .sheet(isPresented: $showSortSheet) {
            MediaSortSheet(sortOption: $sortOption)
                .presentationDetents([.medium])
        }
    }
    
    private func deleteSelectedItems() {
        isDeleting = true
        Task {
            do {
                try await viewModel.deleteItems(withIDs: selectedItems)
                selectedItems.removeAll()
                isSelectionMode = false
                if allItemIDs.isEmpty {
                    dismiss()
                }
            } catch {
                deleteError = error.localizedDescription
            }
            isDeleting = false
        }
    }
}
