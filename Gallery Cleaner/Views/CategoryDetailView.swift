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
        case .grid(let items):
            return Set(items.map { $0.id })
        case .grouped(let groups):
            return Set(groups.flatMap { $0.items }.map { $0.id })
        }
    }
    
    var itemsCount: Int {
        allItemIDs.count
    }
    
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
            
            // X / Back button functionality - Mockup usually has back button when not in selection mode?
            // "The X/close control should exit selection mode or return to the previous screen depending on the current screen state."
            // We have the X button in the top right for exiting selection mode, which is already handled above. 
            // The back button is native on NavigationStack, but since we use .navigationBarHidden(true), we should add a custom back button if not in selection mode, or keep it simple.
            
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
                        if selectedItems.count == allItemIDs.count {
                            selectedItems.removeAll()
                        } else {
                            selectedItems = allItemIDs
                        }
                    }, onDelete: {
                        // Delete action
                    })
                }
            }
        }
        .navigationBarHidden(true)
    }
}
