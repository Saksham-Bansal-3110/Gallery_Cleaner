//
//  CategoryCard.swift
//  Gallery Cleaner
//

import SwiftUI

struct CategoryCard: View {
    var icon: String
    var categoryColor: Color
    var title: String
    var itemsCount: Int
    var totalSize: String
    var items: [MediaItem]
    var isLoading: Bool = false
    var action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 12) {
                            CategoryIcon(systemImage: icon, color: categoryColor)
                            Text(title)
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(.primary)
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel(title)
                        
                        Text("\(itemsCount) Items • \(totalSize)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.primary)
                }
            
            if isLoading {
                VStack(spacing: 8) {
                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .primary))
                    Text("Scanning...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, minHeight: 100)
            } else if items.isEmpty {
                Text("No items found")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(height: 100)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(items.prefix(10)) { item in
                            MediaThumbnail(
                                item: item,
                                isSelected: false,
                                isSelectionMode: false,
                                onTap: {}
                            )
                            .allowsHitTesting(false)
                            .frame(width: 100, height: 100)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .contentShape(Rectangle())
        .cornerRadius(20)
    }
}
