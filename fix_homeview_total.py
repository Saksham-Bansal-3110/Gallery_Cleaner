import re

with open("Gallery Cleaner/Views/HomeView.swift", "r") as f:
    content = f.read()

old_vstack = """                // What's Taking Space Card
                VStack(alignment: .leading, spacing: 16) {
                    Text("Storage Breakdown")
                        .font(.title3.bold())
                        .foregroundStyle(.primary)
                    
                    StorageOverviewView(segments: chartSegments)
                }"""

new_vstack = """                // What's Taking Space Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Storage Breakdown")
                            .font(.title3.bold())
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        Text(viewModel.formatSize(totalStorageSize))
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    
                    StorageOverviewView(segments: chartSegments)
                }"""

content = content.replace(old_vstack, new_vstack)

old_segments = """    var chartSegments: [ChartSegment] {"""

new_segments = """    var totalStorageSize: Int64 {
        viewModel.categoryStatistics.reduce(0) { $0 + $1.totalSize }
    }
    
    var chartSegments: [ChartSegment] {"""

content = content.replace(old_segments, new_segments)

with open("Gallery Cleaner/Views/HomeView.swift", "w") as f:
    f.write(content)

