//
//  CategoryDetailView.swift
//  Gallery Cleaner
//

import SwiftUI

struct CategoryDetailView: View {
    var title: String
    var items: [MediaItem]
    var totalSize: String
    
    @Environment(\.dismiss) var dismiss
    @State private var isSelectionMode = false
    @State private var selectedItems: Set<String> = []
    
    let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]
    
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
                        Text("\(items.count) Items • \(totalSize)")
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
                
                if items.isEmpty {
                    Spacer()
                    Text("No Items")
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    // Grid
                    ScrollView {
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
                                    } else {
                                        // Regular tap action
                                    }
                                }
                                .aspectRatio(1, contentMode: .fit)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 100) // Space for toolbar
                    }
                }
            }
            
            if isSelectionMode {
                VStack {
                    Spacer()
                    SelectionToolbar(onSelectAll: {
                        if selectedItems.count == items.count {
                            selectedItems.removeAll()
                        } else {
                            selectedItems = Set(items.map { $0.id })
                        }
                    }, onDelete: {
                        // Delete action mock
                    })
                }
            }
        }
        .navigationBarHidden(true)
    }
}
