//
//  HomeView.swift
//  Gallery Cleaner
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: GalleryViewModel
    
    var orderedStatistics: [CategoryStatistics] {
        return viewModel.categoryStatistics
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                
                if viewModel.scanState == .idle || viewModel.scanState == .requestingPermission {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                } else if case .scanning = viewModel.scanState {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                } else if viewModel.scanState == .permissionDenied {
                    VStack {
                        Text("Permission Denied")
                            .font(.title)
                            .foregroundStyle(.primary)
                        Text("Please allow photo library access in Settings.")
                            .foregroundStyle(.secondary)
                    }
                } else if case let .failed(errorMsg) = viewModel.scanState {
                    VStack {
                        Text("Scan Failed")
                            .font(.title)
                            .foregroundStyle(.primary)
                        Text(errorMsg)
                            .foregroundStyle(.secondary)
                    }
                } else if viewModel.scanState == .completed && viewModel.allItems.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 64))
                            .foregroundStyle(.secondary)
                        Text("No Media Found")
                            .font(.title)
                            .foregroundStyle(.primary)
                        Text("Your photo library appears to be empty.")
                            .foregroundStyle(.secondary)
                    }
                } else {
                    mainContentView
                }
            }
            .navigationDestination(for: CategoryType.self) { categoryType in
                let title = orderedStatistics.first { $0.categoryType == categoryType }?.title ?? "Category"
                CategoryDetailView(title: title, categoryType: categoryType)
            }
            .navigationBarHidden(true)
            .scrollIndicators(.hidden)
        }
        .task {
            if viewModel.scanState == .idle {
                await viewModel.startScanning()
            }
        }
    }
    
    var mainContentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Title
                Text("Gallery Cleaner")
                    .font(.largeTitle)
                    .foregroundStyle(.primary)
                    .padding(.top, 8)
                
                // What's Taking Space Card
                VStack(alignment: .leading, spacing: 16) {
                    Text("What's Taking Space?")
                        .font(.title3.bold())
                        .foregroundStyle(.primary)
                    
                    StorageOverviewView(segments: chartSegments)
                }
                .padding(20)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(20)
                
                // Categories
                ForEach(orderedStatistics) { stat in
                    let isLoading = stat.categoryType == .similarPhotos && viewModel.isScanningSimilarPhotos
                    
                    if isLoading {
                        CategoryCard(
                            icon: stat.systemImage,
                            categoryColor: stat.categoryType.color,
                            title: stat.title,
                            itemsCount: 0,
                            totalSize: "Calculating...",
                            items: [],
                            isLoading: true
                        ) {}
                        .disabled(true)
                    } else {
                        NavigationLink(value: stat.categoryType) {
                            CategoryCard(
                                icon: stat.systemImage,
                            categoryColor: stat.categoryType.color,
                                title: stat.title,
                                itemsCount: stat.itemCount,
                                totalSize: viewModel.formatSize(stat.totalSize),
                                items: stat.previewItems,
                                isLoading: false
                            ) {}
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
    }
    
    var chartSegments: [ChartSegment] {
        return viewModel.categoryStatistics.map { stat in
            ChartSegment(
                color: stat.color,
                value: Double(stat.totalSize),
                label: stat.title,
                formattedValue: viewModel.formatSize(stat.totalSize),
                itemCount: stat.itemCount
            )
        }
    }
}
