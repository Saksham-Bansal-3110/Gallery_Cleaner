//
//  MediaSizeService.swift
//  Gallery Cleaner
//

import Foundation
import Photos

public actor MediaSizeService {
    public static let shared = MediaSizeService()
    
    private var sizeCache: [String: Int64] = [:]
    
    private init() {}
    
    public func getSize(for asset: PHAsset) async -> Int64 {
        if let cached = sizeCache[asset.localIdentifier] {
            return cached
        }
        
        // Use withCheckedContinuation since assetResources can be slow.
        // For iCloud videos, it may need network access if not local. However, assetResources(for:) usually returns metadata without downloading the full asset.
        let size = await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let resources = PHAssetResource.assetResources(for: asset)
                let totalSize = resources.compactMap { $0.value(forKey: "fileSize") as? Int64 }.reduce(0, +)
                continuation.resume(returning: totalSize)
            }
        }
        
        sizeCache[asset.localIdentifier] = size
        return size
    }
    
    public func clearCache() {
        sizeCache.removeAll()
    }
}
