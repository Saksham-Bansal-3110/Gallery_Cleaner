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
    
    var displayStyle: CategoryDisplayStyle {
        switch categoryType {
        case .screenshots: return .grid(items: viewModel.screenshots)
        case .videos: return .grid(items: viewModel.videos)
        case .duplicatePhotos: return .grouped(groups: viewModel.duplicatePhotos)
        case .similarPhotos: return .grouped(groups: viewModel.similarPhotos)
        case .duplicateVideos: return .grouped(groups: viewModel.duplicateVideos)
        case .largeVideos: return .list(items: viewModel.largeVideos)
        }
    }
    
    let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]
    
    var allItemIDs: Set<String> {
        switch displayStyle {
        case .grid(let items), .list(let items):
            return Set(items.map { $0.id })
        case .grouped(let groups):
            return Set(groups.flatMap { $0.items }.map { $0.id })
        }
    }
    
    var allItemsList: [MediaItem] {
        switch displayStyle {
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
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                if itemsCount == 0 {
                    Spacer()
                    Text("No Items")
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    ScrollView {
                        VStack {
                            Text(itemsCountText)
                                .font(.system(size: 14))
                                .foregroundColor(Color(white: 0.6))
                                .padding(.vertical, 8)
                        }
                        switch displayStyle {
                        case .grid(let items):
                            LazyVGrid(columns: columns, spacing: 8) {
                                ForEach(items) { item in
                                    MediaThumbnail(
                                        item: item,
                                        isSelected: selectedItems.contains(item.id),
                                        isSelectionMode: isSelectionMode
                                    ) {
                                        if isSelectionMode && !isDeleting {
                                            if selectedItems.contains(item.id) {
                                                selectedItems.remove(item.id)
                                            } else {
                                                selectedItems.insert(item.id)
                                            }
                                        }
                                    }
                                    .aspectRatio(1, contentMode: .fit)
                                    .opacity(isDeleting ? 0.5 : 1.0)
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
                                                    .foregroundColor(selectedItems.contains(item.id) ? .blue : .white)
                                                    .background(
                                                        Circle()
                                                            .fill(selectedItems.contains(item.id) ? Color.white : Color.clear)
                                                            .frame(width: 18, height: 18)
                                                    )
                                            }
                                            .disabled(isDeleting)
                                        }
                                        
                                        MediaThumbnail(item: item, isSelected: false, isSelectionMode: false) { }
                                            .frame(width: 80, height: 80)
                                            .cornerRadius(8)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(item.filename ?? "Unknown")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.white)
                                                .lineLimit(1)
                                            
                                            HStack(spacing: 8) {
                                                Text(item.formattedSize)
                                                    .font(.system(size: 14))
                                                    .foregroundColor(Color(white: 0.6))
                                                
                                                if let duration = item.formattedDuration {
                                                    Text("•")
                                                        .foregroundColor(Color(white: 0.4))
                                                    Text(duration)
                                                        .font(.system(size: 14))
                                                        .foregroundColor(Color(white: 0.6))
                                                }
                                            }
                                        }
                                        Spacer()
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(Color(white: 0.12))
                                    .cornerRadius(12)
                                    .padding(.horizontal, 16)
                                    .opacity(isDeleting ? 0.5 : 1.0)
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

            
            if isDeleting {
                Color.black.opacity(0.4).ignoresSafeArea()
                ProgressView("Deleting & Refreshing...")
                    .foregroundColor(.white)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .padding(24)
                    .background(Color(white: 0.2))
                    .cornerRadius(16)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
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
                        if case .grouped(let groups) = displayStyle, categoryType != .similarPhotos {
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
