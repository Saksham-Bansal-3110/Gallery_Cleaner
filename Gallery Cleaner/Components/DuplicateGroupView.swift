//
//  DuplicateGroupView.swift
//  Gallery Cleaner
//

import SwiftUI

struct DuplicateGroupView: View {
    var group: DuplicateGroup
    @Binding var selectedItems: Set<String>
    var isSelectionMode: Bool
    
    var isFullySelected: Bool {
        let itemIDs = Set(group.items.map { $0.id })
        return !itemIDs.isEmpty && selectedItems.isSuperset(of: itemIDs)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(group.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                Spacer()
                
                if isSelectionMode {
                    Button(action: toggleGroupSelection) {
                        Image(systemName: isFullySelected ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 20))
                            .foregroundColor(isFullySelected ? .blue : .white)
                            .background(
                                Circle()
                                    .fill(isFullySelected ? Color.white : Color.clear)
                                    .frame(width: 18, height: 18)
                            )
                    }
                }
            }
            
            if group.items.count > 2 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(group.items) { item in
                            MediaThumbnail(
                                item: item,
                                isSelected: selectedItems.contains(item.id),
                                isSelectionMode: isSelectionMode,
                                isRecommended: group.recommendedItem?.id == item.id,
                                onTap: {
                                    if isSelectionMode {
                                        if selectedItems.contains(item.id) {
                                            selectedItems.remove(item.id)
                                        } else {
                                            selectedItems.insert(item.id)
                                        }
                                    }
                                }
                            )
                            .frame(width: 120, height: 120)
                        }
                    }
                }
            } else {
                HStack(spacing: 12) {
                    ForEach(group.items) { item in
                        MediaThumbnail(
                            item: item,
                            isSelected: selectedItems.contains(item.id),
                            isSelectionMode: isSelectionMode,
                            onTap: {
                                if isSelectionMode {
                                    if selectedItems.contains(item.id) {
                                        selectedItems.remove(item.id)
                                    } else {
                                        selectedItems.insert(item.id)
                                    }
                                }
                            }
                        )
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fit)
                    }
                }
            }
        }
        .padding(16)
        .background(Color(white: 0.12))
        .cornerRadius(12)
    }
    
    private func toggleGroupSelection() {
        let itemIDs = Set(group.items.map { $0.id })
        if isFullySelected {
            selectedItems.subtract(itemIDs)
        } else {
            selectedItems.formUnion(itemIDs)
        }
    }
}
