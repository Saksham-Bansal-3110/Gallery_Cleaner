//
//  GalleryViewModel.swift
//  Gallery Cleaner
//

import Foundation
import Combine
import Photos
import UIKit

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
                self.similarPhotos = await similarScanner.scanSimilarPhotos(from: items)
                
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
        self.similarPhotos = await similarScanner.scanSimilarPhotos(from: allItems)
    }
}
