//
//  StorageDonutChart.swift
//  Gallery Cleaner
//

import SwiftUI

struct ChartSegment: Identifiable {
    let id = UUID()
    let color: Color
    let value: Double
    let label: String
    let formattedValue: String
    let itemCount: Int
}

struct StorageDonutChart: View {
    let segments: [ChartSegment]
    
    var body: some View {
        HStack(spacing: 24) {
            // Donut Chart
            ZStack {
                Circle()
                    .stroke(Color(white: 0.2), lineWidth: 12)
                
                let total = segments.reduce(0) { $0 + $1.value }
                let currentAngle: Double = -90
                
                ForEach(segments) { segment in
                    let angle = (segment.value / total) * 360
                    let endAngle = currentAngle + angle
                    
                    Path { path in
                        path.addArc(center: CGPoint(x: 60, y: 60), radius: 60, startAngle: .degrees(currentAngle), endAngle: .degrees(endAngle), clockwise: false)
                    }
                    .stroke(segment.color, style: StrokeStyle(lineWidth: 12, lineCap: .butt))
                    .frame(width: 120, height: 120)
                    
                    // Invisible view to compute the next start angle. Swift doesn't allow inline mutation in ForEach easily, but we can compute angles before ForEach or use custom shape.
                    // For simplicity in mock, just use a placeholder shape or custom calculation if needed.
                    // Actually, let's use a better approach for angles.
                }
            }
            .frame(width: 120, height: 120)
            
            // Legend
            VStack(alignment: .leading, spacing: 6) {
                ForEach(segments) { segment in
                    HStack(spacing: 6) {
                        Rectangle()
                            .fill(segment.color)
                            .frame(width: 8, height: 8)
                            .cornerRadius(2)
                        Text(segment.label)
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .padding()
    }
}

// A better way to draw the pie chart to avoid inline state mutation:
struct DonutChartShape: View {
    let segments: [ChartSegment]
    
    var body: some View {
        let total = segments.reduce(0) { $0 + $1.value }
        var startAngles: [Double] = []
        var current: Double = -90
        for seg in segments {
            startAngles.append(current)
            current += (seg.value / (total == 0 ? 1 : total)) * 360
        }
        
        return ZStack {
            ForEach(0..<segments.count, id: \.self) { index in
                let segment = segments[index]
                let startAngle = startAngles[index]
                let angle = (segment.value / (total == 0 ? 1 : total)) * 360
                
                Path { path in
                    path.addArc(center: CGPoint(x: 75, y: 75), radius: 60, startAngle: .degrees(startAngle), endAngle: .degrees(startAngle + angle), clockwise: false)
                }
                .stroke(segment.color, style: StrokeStyle(lineWidth: 12, lineCap: .butt))
            }
        }
        .frame(width: 150, height: 150)
    }
}

// Re-defining StorageDonutChart using the shape
struct StorageDonutChartView: View {
    let segments: [ChartSegment]
    
    var body: some View {
        HStack(spacing: 32) {
            ZStack {
                if segments.isEmpty {
                    Circle()
                        .stroke(Color(white: 0.3), style: StrokeStyle(lineWidth: 12, lineCap: .butt))
                        .frame(width: 150, height: 150)
                } else {
                    DonutChartShape(segments: segments)
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                if segments.isEmpty {
                    Text("No Media Yet")
                        .foregroundColor(.gray)
                        .font(.system(size: 14))
                } else {
                    ForEach(segments) { segment in
                        HStack(spacing: 6) {
                            Rectangle()
                                .fill(segment.color)
                                .frame(width: 8, height: 8)
                                .cornerRadius(2)
                                .layoutPriority(2)
                            Text(segment.label)
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                                .layoutPriority(1)
                            Spacer(minLength: 4)
                            Text(segment.formattedValue)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color(white: 0.7))
                                .lineLimit(1)
                                .fixedSize(horizontal: true, vertical: false)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 24)
        .background(Color(white: 0.12))
        .cornerRadius(20)
    }
}
