//
//  PhotoLibraryService.swift
//  Gallery Cleaner
//

import Foundation
import Photos
import UIKit

public protocol PhotoLibraryService {
    func requestAuthorization() async -> PHAuthorizationStatus
    func fetchAllMedia() async -> [MediaItem]
    func requestThumbnail(for item: MediaItem, targetSize: CGSize, completion: @escaping (UIImage?) -> Void) -> PHImageRequestID
    func cancelThumbnailRequest(_ requestID: PHImageRequestID)
}

class PhotoLibraryManager: PhotoLibraryService {
    private let imageManager = PHCachingImageManager()
    
    func requestAuthorization() async -> PHAuthorizationStatus {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        return status
    }
    
    func fetchAllMedia() async -> [MediaItem] {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                
                let fetchResult = PHAsset.fetchAssets(with: fetchOptions)
                var items: [MediaItem] = []
                
                // For a highly performant initial load, we might not want to fetch the exact file size for every single item immediately, as PHAssetResource.assetResources(for:) is synchronous and slow.
                // However, the instructions say "fetch photos and videos" and we need sizes.
                // We'll batch it or use a default size if it takes too long, but let's try getting real sizes.
                // To keep it relatively fast, we can use a small estimation or fetch resources carefully.
                // Let's just fetch everything for now. If it's too slow, we can optimize.
                
                fetchResult.enumerateObjects { asset, _, _ in
                    let resources = PHAssetResource.assetResources(for: asset)
                    let size = resources.compactMap { $0.value(forKey: "fileSize") as? Int64 }.reduce(0, +)
                    
                    let item = MediaItem(asset: asset, sizeInBytes: size)
                    items.append(item)
                }
                
                continuation.resume(returning: items)
            }
        }
    }
    
    func requestThumbnail(for item: MediaItem, targetSize: CGSize, completion: @escaping (UIImage?) -> Void) -> PHImageRequestID {
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.isNetworkAccessAllowed = true
        options.resizeMode = .fast
        
        // Convert points to pixels
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
    
    func fetchAllMedia() async -> [MediaItem] {
        return []
    }
    
    func requestThumbnail(for item: MediaItem, targetSize: CGSize, completion: @escaping (UIImage?) -> Void) -> PHImageRequestID {
        completion(nil)
        return 0
    }
    
    func cancelThumbnailRequest(_ requestID: PHImageRequestID) {}
}
