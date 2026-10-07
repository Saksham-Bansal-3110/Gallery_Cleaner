//
//  PhotoLibraryService.swift
//  Gallery Cleaner
//

import Foundation
import Photos
import UIKit

public protocol PhotoLibraryService {
    func requestAuthorization() async -> PHAuthorizationStatus
    func fetchAllMedia() -> AsyncStream<([MediaItem], Double)>
    func requestThumbnail(for item: MediaItem, targetSize: CGSize, completion: @escaping (UIImage?) -> Void) -> PHImageRequestID
    func cancelThumbnailRequest(_ requestID: PHImageRequestID)
}

class PhotoLibraryManager: PhotoLibraryService {
    private let imageManager = PHCachingImageManager()
    
    func requestAuthorization() async -> PHAuthorizationStatus {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        return status
    }
    
    func fetchAllMedia() -> AsyncStream<([MediaItem], Double)> {
        AsyncStream { continuation in
            Task {
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                
                let fetchResult = PHAsset.fetchAssets(with: fetchOptions)
                let totalCount = fetchResult.count
                var items: [MediaItem] = []
                
                if totalCount == 0 {
                    continuation.yield((items, 1.0))
                    continuation.finish()
                    return
                }
                
                for i in 0..<totalCount {
                    let asset = fetchResult.object(at: i)
                    let item = MediaItem(asset: asset, sizeInBytes: 0)
                    items.append(item)
                }
                
                continuation.yield((items, 0.1))
                
                var processedCount = 0
                for i in 0..<items.count {
                    let asset = items[i].asset
                    let sizeAndName = await MediaSizeService.shared.getSizeAndFilename(for: asset)
                    items[i].sizeInBytes = sizeAndName.0
                    items[i].filename = sizeAndName.1
                    
                    processedCount += 1
                    if processedCount % 10 == 0 || processedCount == totalCount {
                        let progress = 0.1 + (0.9 * Double(processedCount) / Double(totalCount))
                        continuation.yield((items, progress))
                    }
                }
                
                continuation.finish()
            }
        }
    }
    
    func requestThumbnail(for item: MediaItem, targetSize: CGSize, completion: @escaping (UIImage?) -> Void) -> PHImageRequestID {
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.isNetworkAccessAllowed = true
        options.resizeMode = .fast
        
        let scale = UIScreen.main.scale
        let pixelSize = CGSize(width: targetSize.width * scale, height: targetSize.height * scale)
        
        return imageManager.requestImage(for: item.asset, targetSize: pixelSize, contentMode: .aspectFill, options: options) { image, _ in
            completion(image)
        }
    }
    
    func cancelThumbnailRequest(_ requestID: PHImageRequestID) {
        imageManager.cancelImageRequest(requestID)
    }
}

class MockPhotoLibraryService: PhotoLibraryService {
    func requestAuthorization() async -> PHAuthorizationStatus {
        return .authorized
    }
    
    func fetchAllMedia() -> AsyncStream<([MediaItem], Double)> {
        AsyncStream { continuation in
            continuation.yield(([], 1.0))
            continuation.finish()
        }
    }
    
    func requestThumbnail(for item: MediaItem, targetSize: CGSize, completion: @escaping (UIImage?) -> Void) -> PHImageRequestID {
        completion(nil)
        return 0
    }
    
    func cancelThumbnailRequest(_ requestID: PHImageRequestID) {}
}
