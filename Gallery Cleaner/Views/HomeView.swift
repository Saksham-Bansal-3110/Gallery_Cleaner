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
                Color.black.ignoresSafeArea()
                
                if viewModel.scanState == .idle || viewModel.scanState == .requestingPermission {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else if case .scanning = viewModel.scanState {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else if viewModel.scanState == .permissionDenied {
                    VStack {
                        Text("Permission Denied")
                            .font(.title)
                            .foregroundColor(.white)
                        Text("Please allow photo library access in Settings.")
                            .foregroundColor(.gray)
                    }
                } else if case let .failed(errorMsg) = viewModel.scanState {
                    VStack {
                        Text("Scan Failed")
                            .font(.title)
                            .foregroundColor(.white)
                        Text(errorMsg)
                            .foregroundColor(.gray)
                    }
                } else if viewModel.scanState == .completed && viewModel.allItems.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 64))
                            .foregroundColor(.gray)
                        Text("No Media Found")
                            .font(.title)
                            .foregroundColor(.white)
                        Text("Your photo library appears to be empty.")
                            .foregroundColor(.gray)
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
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 8)
                
                // What's Taking Space Card
                VStack(alignment: .leading, spacing: 16) {
                    Text("What's Taking Space?")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    
                    StorageOverviewView(segments: chartSegments)
                }
                .padding(20)
                .background(Color(white: 0.12))
                .cornerRadius(20)
                
                // Categories
                ForEach(orderedStatistics) { stat in
                    NavigationLink(value: stat.categoryType) {
                        CategoryCard(
                            title: stat.title,
                            itemsCount: stat.itemCount,
                            totalSize: viewModel.formatSize(stat.totalSize),
                            items: stat.previewItems
                        ) {}
                    }
                    .buttonStyle(PlainButtonStyle())
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
