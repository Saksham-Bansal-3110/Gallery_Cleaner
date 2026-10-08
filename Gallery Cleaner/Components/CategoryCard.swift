//
//  CategoryCard.swift
//  Gallery Cleaner
//

import SwiftUI

struct CategoryCard: View {
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
                        Text(title)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.white)
                        Text("\(itemsCount) Items • \(totalSize)")
                            .font(.system(size: 14))
                            .foregroundColor(Color(white: 0.6))
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
            
            if isLoading {
                VStack(spacing: 8) {
                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                    Text("Scanning...")
                        .font(.system(size: 14))
                        .foregroundColor(Color(white: 0.5))
                }
                .frame(maxWidth: .infinity, minHeight: 100)
            } else if items.isEmpty {
                Text("No items found")
                    .font(.system(size: 14))
                    .foregroundColor(Color(white: 0.5))
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
        .background(Color(white: 0.12))
        .contentShape(Rectangle())
        .cornerRadius(20)
    }
}
