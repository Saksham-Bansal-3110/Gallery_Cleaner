//
//  DuplicateGroupView.swift
//  Gallery Cleaner
//

import SwiftUI

struct DuplicateGroupView: View {
    var title: String
    var isSelected: Bool
    var onToggleSelection: () -> Void
    var itemsCount: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                Spacer()
                
                Button(action: onToggleSelection) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 20))
                        .foregroundColor(isSelected ? .blue : .white)
                        .background(
                            Circle()
                                .fill(isSelected ? Color.white : Color.clear)
                                .frame(width: 18, height: 18)
                        )
                }
            }
            
            HStack(spacing: 12) {
                ForEach(0..<itemsCount, id: \.self) { _ in
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(white: 0.3))
                            .aspectRatio(1, contentMode: .fit)
                        
                        Text("12 MB")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.white.opacity(0.3))
                            .clipShape(Capsule())
                            .padding(6)
                    }
                }
            }
        }
        .padding(16)
        .background(Color(white: 0.12))
        .cornerRadius(12)
    }
}
