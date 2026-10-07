//
//  HomeView.swift
//  Gallery Cleaner
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: GalleryViewModel
    @State private var navigateToScreenshots = false
    @State private var navigateToDuplicates = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if viewModel.scanState == .idle || viewModel.scanState == .requestingPermission {
                    VStack {
                        ProgressView("Scanning Library...")
                            .foregroundColor(.white)
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                } else if viewModel.scanState == .permissionDenied {
                    VStack {
                        Text("Permission Denied")
                            .font(.title)
                            .foregroundColor(.white)
                        Text("Please allow photo library access in Settings.")
                            .foregroundColor(.gray)
                    }
                } else {
                    mainContentView
                }
            }
            .navigationDestination(isPresented: $navigateToScreenshots) {
                CategoryDetailView(
                    title: "Screenshots",
                    items: viewModel.screenshots,
                    totalSize: viewModel.formatSize(viewModel.totalSize(for: viewModel.screenshots))
                )
            }
            .navigationDestination(isPresented: $navigateToDuplicates) {
                // Keep it mocked for now as per instructions: "Do not yet implement duplicate/similarity analysis"
                DuplicatesView()
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
                    
                    StorageDonutChartView(segments: chartSegments)
                }
                .padding(20)
                .background(Color(white: 0.12))
                .cornerRadius(20)
                
                // Categories
                CategoryCard(
                    title: "Screenshots",
                    itemsCount: viewModel.screenshots.count,
                    totalSize: viewModel.formatSize(viewModel.totalSize(for: viewModel.screenshots)),
                    items: viewModel.screenshots
                ) {
                    navigateToScreenshots = true
                }
                
                CategoryCard(
                    title: "Videos",
                    itemsCount: viewModel.videos.count,
                    totalSize: viewModel.formatSize(viewModel.totalSize(for: viewModel.videos)),
                    items: viewModel.videos
                ) {
                    // Action
                }
                
                CategoryCard(
                    title: "Duplicate Photos",
                    itemsCount: viewModel.duplicatePhotos.count,
                    totalSize: viewModel.formatSize(viewModel.totalSize(for: viewModel.duplicatePhotos)),
                    items: viewModel.duplicatePhotos
                ) {
                    navigateToDuplicates = true
                }
                
                CategoryCard(
                    title: "Similar Photos",
                    itemsCount: viewModel.similarPhotos.count,
                    totalSize: viewModel.formatSize(viewModel.totalSize(for: viewModel.similarPhotos)),
                    items: viewModel.similarPhotos
                ) {
                    // Action
                }
                
                CategoryCard(
                    title: "Duplicate Videos",
                    itemsCount: viewModel.duplicateVideos.count,
                    totalSize: viewModel.formatSize(viewModel.totalSize(for: viewModel.duplicateVideos)),
                    items: viewModel.duplicateVideos
                ) {
                    // Action
                }
                
                CategoryCard(
                    title: "Large Videos",
                    itemsCount: viewModel.largeVideos.count,
                    totalSize: viewModel.formatSize(viewModel.totalSize(for: viewModel.largeVideos)),
                    items: viewModel.largeVideos
                ) {
                    // Action
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
    }
    
    var chartSegments: [ChartSegment] {
        return [
            ChartSegment(color: .red, value: Double(max(1, viewModel.totalSize(for: viewModel.screenshots))), label: "Screenshots"),
            ChartSegment(color: .green, value: Double(max(1, viewModel.totalSize(for: viewModel.videos))), label: "Videos"),
            ChartSegment(color: .cyan, value: Double(max(1, viewModel.totalSize(for: viewModel.duplicatePhotos))), label: "Duplicate Photos"),
            ChartSegment(color: .purple, value: Double(max(1, viewModel.totalSize(for: viewModel.similarPhotos))), label: "Similar Photos"),
            ChartSegment(color: .orange, value: Double(max(1, viewModel.totalSize(for: viewModel.duplicateVideos))), label: "Duplicate Videos"),
            ChartSegment(color: .blue, value: Double(max(1, viewModel.totalSize(for: viewModel.largeVideos))), label: "Large Videos")
        ]
    }
}
