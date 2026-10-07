//
//  GalleryViewModel.swift
//  Gallery Cleaner
//

import Foundation
import Combine
import Photos
import UIKit

import SwiftUI

public enum CategoryType {
    case screenshots
    case videos
    case duplicatePhotos
    case similarPhotos
    case duplicateVideos
    case largeVideos
}

struct CategoryStatistics: Identifiable {
    let id = UUID()
    let categoryType: CategoryType
    let title: String
    let itemCount: Int
    let totalSize: Int64
    let previewItems: [MediaItem]
    let color: Color
}

@MainActor
class GalleryViewModel: ObservableObject {
    let photoLibraryService: PhotoLibraryService
    
    @Published var scanState: ScanState = .idle
    @Published var allItems: [MediaItem] = []
    
    @Published var screenshots: [MediaItem] = []
    @Published var videos: [MediaItem] = []
    
    // We'll populate these later in the duplicate phase
    @Published var duplicatePhotos: [DuplicateGroup] = []
    @Published var similarPhotos: [DuplicateGroup] = []
    @Published var duplicateVideos: [DuplicateGroup] = []
    @Published var largeVideos: [MediaItem] = []
    
    init(photoLibraryService: PhotoLibraryService) {
        self.photoLibraryService = photoLibraryService
    }
    
    func startScanning() async {
        if case .scanning = scanState { return }
        
        self.scanState = .requestingPermission
        let status = await photoLibraryService.requestAuthorization()
        
        switch status {
        case .authorized, .limited:
            self.scanState = .scanning(progress: 0.0)
            
            let stream = photoLibraryService.fetchAllMedia()
            for await (items, progress) in stream {
                self.allItems = items
                
                let screenshotScanner = ScreenshotScanner()
                self.screenshots = screenshotScanner.scanScreenshots(from: items)
                
                let videoScanner = VideoScanner()
                self.videos = videoScanner.scanVideos(from: items)
                
                self.largeVideos = self.videos
                    .filter { $0.sizeInBytes >= AppConfig.largeVideoThreshold }
                    .sorted { $0.sizeInBytes > $1.sizeInBytes }
                
                let duplicateScanner = DuplicatePhotoScanner()
                self.duplicatePhotos = await duplicateScanner.scanDuplicates(from: items)
                
                let duplicateVideoScanner = DuplicateVideoScanner()
                self.duplicateVideos = await duplicateVideoScanner.scanDuplicates(from: items)
                
                let similarScanner = SimilarPhotoScanner()
                let exactIDs = Set(self.duplicatePhotos.flatMap { $0.items }.map { $0.id })
                self.similarPhotos = await similarScanner.scanSimilarPhotos(from: items, exactDuplicateIDs: exactIDs)
                
                if progress >= 1.0 {
                    self.scanState = .completed
                } else {
                    self.scanState = .scanning(progress: progress)
                }
            }
            
        case .denied, .restricted:
            self.scanState = .permissionDenied
        case .notDetermined:
            self.scanState = .idle
        @unknown default:
            self.scanState = .failed("Unknown authorization status")
        }
    }
    
    func totalSize(for items: [MediaItem]) -> Int64 {
        return items.reduce(0) { $0 + $1.sizeInBytes }
    }
    
    func totalSize(for groups: [DuplicateGroup]) -> Int64 {
        let uniqueItems = Set(groups.flatMap { $0.items })
        return uniqueItems.reduce(0) { $0 + $1.sizeInBytes }
    }
    
    func formatSize(_ size: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
    
    var categoryStatistics: [CategoryStatistics] {
        return [
            CategoryStatistics(categoryType: .screenshots, title: "Screenshots", itemCount: screenshots.count, totalSize: totalSize(for: screenshots), previewItems: Array(screenshots.prefix(10)), color: .red),
            CategoryStatistics(categoryType: .videos, title: "Videos", itemCount: videos.count, totalSize: totalSize(for: videos), previewItems: Array(videos.prefix(10)), color: .green),
            CategoryStatistics(categoryType: .duplicatePhotos, title: "Duplicate Photos", itemCount: Set(duplicatePhotos.flatMap { $0.items }).count, totalSize: totalSize(for: duplicatePhotos), previewItems: Array(duplicatePhotos.flatMap { $0.items }.prefix(10)), color: .cyan),
            CategoryStatistics(categoryType: .similarPhotos, title: "Similar Photos", itemCount: Set(similarPhotos.flatMap { $0.items }).count, totalSize: totalSize(for: similarPhotos), previewItems: Array(similarPhotos.flatMap { $0.items }.prefix(10)), color: .purple),
            CategoryStatistics(categoryType: .duplicateVideos, title: "Duplicate Videos", itemCount: Set(duplicateVideos.flatMap { $0.items }).count, totalSize: totalSize(for: duplicateVideos), previewItems: Array(duplicateVideos.flatMap { $0.items }.prefix(10)), color: .orange),
            CategoryStatistics(categoryType: .largeVideos, title: "Large Videos", itemCount: largeVideos.count, totalSize: totalSize(for: largeVideos), previewItems: Array(largeVideos.prefix(10)), color: .blue)
        ]
    }
    
    func deleteItems(withIDs ids: Set<String>) async throws {
        let itemsToDelete = allItems.filter { ids.contains($0.id) }
        guard !itemsToDelete.isEmpty else { return }
        
        try await photoLibraryService.deleteMedia(items: itemsToDelete)
        
        // On success, update UI state by removing the deleted items
        self.allItems.removeAll { ids.contains($0.id) }
        
        let screenshotScanner = ScreenshotScanner()
        self.screenshots = screenshotScanner.scanScreenshots(from: allItems)
        
        let videoScanner = VideoScanner()
        self.videos = videoScanner.scanVideos(from: allItems)
        
        self.largeVideos = self.videos
            .filter { $0.sizeInBytes >= AppConfig.largeVideoThreshold }
            .sorted { $0.sizeInBytes > $1.sizeInBytes }
        
        let duplicateScanner = DuplicatePhotoScanner()
        self.duplicatePhotos = await duplicateScanner.scanDuplicates(from: allItems)
        
        let duplicateVideoScanner = DuplicateVideoScanner()
        self.duplicateVideos = await duplicateVideoScanner.scanDuplicates(from: allItems)
        
        let similarScanner = SimilarPhotoScanner()
        let exactIDs = Set(self.duplicatePhotos.flatMap { $0.items }.map { $0.id })
        self.similarPhotos = await similarScanner.scanSimilarPhotos(from: allItems, exactDuplicateIDs: exactIDs)
    }
}
