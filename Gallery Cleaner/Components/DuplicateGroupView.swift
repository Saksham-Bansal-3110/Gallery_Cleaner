//
//  DuplicateGroupView.swift
//  Gallery Cleaner
//

import SwiftUI

struct DuplicateGroupView: View {
    var group: DuplicateGroup
    @Binding var selectedItems: Set<String>
    var isSelectionMode: Bool
    

    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(group.title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)
                Spacer()
            }
            
            let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(group.items) { item in
                    Group {
                        if isSelectionMode {
                            Button(action: {
                                if selectedItems.contains(item.id) { selectedItems.remove(item.id) }
                                else { selectedItems.insert(item.id) }
                            }) {
                                MediaThumbnail(
                                    item: item,
                                    isSelected: selectedItems.contains(item.id),
                                    isSelectionMode: isSelectionMode,
                                    isRecommended: group.recommendedItem?.id == item.id,
                                    onTap: {}
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        } else {
                            NavigationLink(value: item) {
                                MediaThumbnail(
                                    item: item,
                                    isSelected: false,
                                    isSelectionMode: false,
                                    isRecommended: group.recommendedItem?.id == item.id,
                                    onTap: {}
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .aspectRatio(1, contentMode: .fit)
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    

}
