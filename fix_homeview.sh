sed -i '' '132,$d' "Gallery Cleaner/Views/HomeView.swift"
cat << 'INNER_EOF' >> "Gallery Cleaner/Views/HomeView.swift"
    var chartSegments: [ChartSegment] {
        return viewModel.categoryStatistics.map { stat in
            ChartSegment(
                color: stat.color,
                value: Double(stat.totalSize),
                label: stat.title,
                formattedValue: viewModel.formatSize(stat.totalSize)
            )
        }.filter { $0.value > 0 }
    }
}
INNER_EOF
