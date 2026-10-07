//
//  MediaSizeService.swift
//  Gallery Cleaner
//

import Foundation
import Photos

public actor MediaSizeService {
    public static let shared = MediaSizeService()
    
    private var sizeCache: [String: (Int64, String?)] = [:]
    
    private init() {}
    
    public func getSizeAndFilename(for asset: PHAsset) async -> (Int64, String?) {
        if let cached = sizeCache[asset.localIdentifier] {
            return cached
        }
        
        let result = await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let resources = PHAssetResource.assetResources(for: asset)
                let totalSize = resources.compactMap { $0.value(forKey: "fileSize") as? Int64 }.reduce(0, +)
                let filename = resources.first?.originalFilename
                
                #if DEBUG
                if totalSize == 0 {
                    print("MediaSizeService: Could not determine size for asset \(asset.localIdentifier)")
                }
                #endif
                
                continuation.resume(returning: (totalSize, filename))
            }
        }
        
        sizeCache[asset.localIdentifier] = result
        return result
    }
    
    public func clearCache() {
        sizeCache.removeAll()
    }
}
