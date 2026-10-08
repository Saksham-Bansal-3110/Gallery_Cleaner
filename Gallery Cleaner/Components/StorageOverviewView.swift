//
//  StorageOverviewView.swift
//  Gallery Cleaner
//

import SwiftUI

struct StorageOverviewView: View {
    let segments: [ChartSegment]
    
    var totalSize: Double {
        segments.reduce(0) { $0 + $1.value }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Segmented Bar
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    if totalSize == 0 {
                        Rectangle()
                            .fill(Color(.tertiaryLabel))
                    } else {
                        ForEach(segments) { segment in
                            if segment.value > 0 {
                                Rectangle()
                                    .fill(segment.color)
                                    .frame(width: max(0, CGFloat(segment.value / totalSize) * geometry.size.width))
                            }
                        }
                    }
                }
                .frame(height: 12)
                .cornerRadius(6)
            }
            .frame(height: 12)
            
            // 2x3 Grid
            LazyVGrid(columns: [GridItem(.flexible(), alignment: .leading), GridItem(.flexible(), alignment: .leading)], spacing: 16) {
                ForEach(segments) { segment in
                    HStack(alignment: .top, spacing: 8) {
                        Circle()
                            .fill(segment.color)
                            .frame(width: 8, height: 8)
                            .padding(.top, 4)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(segment.label)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.primary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                            
                            Text("\(segment.itemCount) • \(segment.formattedValue)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
    }
}
