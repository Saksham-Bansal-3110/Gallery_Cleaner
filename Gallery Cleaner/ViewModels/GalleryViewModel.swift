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
                
                self.largeVideos = self.videos.filter { $0.sizeInBytes > 50 * 1024 * 1024 }
                
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
        return groups.reduce(0) { sum, group in
            sum + totalSize(for: group.items)
        }
    }
    
    func formatSize(_ size: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
}
