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
    @Published var duplicatePhotos: [MediaItem] = []
    @Published var similarPhotos: [MediaItem] = []
    @Published var duplicateVideos: [MediaItem] = []
    @Published var largeVideos: [MediaItem] = []
    
    init(photoLibraryService: PhotoLibraryService) {
        self.photoLibraryService = photoLibraryService
    }
    
    func startScanning() async {
        self.scanState = .requestingPermission
        let status = await photoLibraryService.requestAuthorization()
        
        switch status {
        case .authorized, .limited:
            self.scanState = .scanning
            let items = await photoLibraryService.fetchAllMedia()
            self.allItems = items
            
            let screenshotScanner = ScreenshotScanner()
            self.screenshots = screenshotScanner.scanScreenshots(from: items)
            
            self.videos = items.filter { $0.mediaType == .video }
            
            // Large videos (> 50 MB for example)
            self.largeVideos = self.videos.filter { $0.sizeInBytes > 50 * 1024 * 1024 }
            
            self.scanState = .completed
            
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
    
    func formatSize(_ size: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
}
