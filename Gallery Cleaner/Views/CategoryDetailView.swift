//
//  CategoryDetailView.swift
//  Gallery Cleaner
//

import SwiftUI

struct CategoryDetailView: View {
    var title: String
    var displayStyle: CategoryDisplayStyle
    var totalSize: String
    
    @Environment(\.dismiss) var dismiss
    @State private var isSelectionMode = false
    @State private var selectedItems: Set<String> = []
    
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
    
    var itemsCount: Int {
        allItemIDs.count
    }
    
    @EnvironmentObject var viewModel: GalleryViewModel
    @State private var showDeleteConfirmation = false
    @State private var deleteError: String? = nil
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.white)
                        Text("\(itemsCount) Items • \(totalSize)")
                            .font(.system(size: 14))
                            .foregroundColor(Color(white: 0.6))
                    }
                    Spacer()
                    
                    if isSelectionMode {
                        Button(action: {
                            isSelectionMode = false
                            selectedItems.removeAll()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color(white: 0.4))
                                .clipShape(Circle())
                        }
                    } else {
                        Button(action: {
                            isSelectionMode = true
                            if case .grouped(let groups) = displayStyle {
                                for group in groups {
                                    let itemsToSelect = group.items.dropFirst()
                                    for item in itemsToSelect {
                                        selectedItems.insert(item.id)
                                    }
                                }
                            }
                        }) {
                            Text("Select")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color(white: 0.4))
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 16)
                
                if itemsCount == 0 {
                    Spacer()
                    Text("No Items")
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    ScrollView {
                        switch displayStyle {
                        case .grid(let items):
                            LazyVGrid(columns: columns, spacing: 8) {
                                ForEach(items) { item in
                                    MediaThumbnail(
                                        item: item,
                                        isSelected: selectedItems.contains(item.id),
                                        isSelectionMode: isSelectionMode
                                    ) {
                                        if isSelectionMode {
                                            if selectedItems.contains(item.id) {
                                                selectedItems.remove(item.id)
                                            } else {
                                                selectedItems.insert(item.id)
                                            }
                                        }
                                    }
                                    .aspectRatio(1, contentMode: .fit)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 100)
                            
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
                                }
                            }
                            .padding(.bottom, 100)
                            
                        case .grouped(let groups):
                            LazyVStack(spacing: 16) {
                                ForEach(groups) { group in
                                    DuplicateGroupView(
                                        group: group,
                                        selectedItems: $selectedItems,
                                        isSelectionMode: isSelectionMode
                                    )
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 100)
                        }
                    }
                }
            }
            
            VStack {
                HStack {
                    if !isSelectionMode {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .padding()
                        }
                    }
                    Spacer()
                }
                Spacer()
            }
            
            if isSelectionMode {
                VStack {
                    Spacer()
                    SelectionToolbar(onSelectAll: {
                        let targetIDs: Set<String>
                        if case .grouped(let groups) = displayStyle {
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
                }
            }
        }
        .navigationBarHidden(true)
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
        }
    }
}
