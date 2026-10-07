//
//  MediaHashService.swift
//  Gallery Cleaner
//

import Foundation
import Photos
import CryptoKit

public actor MediaHashService {
    public static let shared = MediaHashService()
    
    private var hashCache: [String: String] = [:]
    
    private init() {}
    
    public func getHash(for asset: PHAsset) async -> String? {
        if let cached = hashCache[asset.localIdentifier] {
            return cached
        }
        
        let hash = await computeHash(for: asset)
        if let hash = hash {
            hashCache[asset.localIdentifier] = hash
        }
        return hash
    }
    
    private func computeHash(for asset: PHAsset) async -> String? {
        return await withCheckedContinuation { continuation in
            let resources = PHAssetResource.assetResources(for: asset)
            guard let resource = resources.first(where: { $0.type == .photo || $0.type == .video || $0.type == .audio }) ?? resources.first else {
                continuation.resume(returning: nil)
                return
            }
            
            let options = PHAssetResourceRequestOptions()
            options.isNetworkAccessAllowed = true
            
            var hasher = SHA256()
            
            PHAssetResourceManager.default().requestData(for: resource, options: options, dataReceivedHandler: { data in
                hasher.update(data: data)
            }, completionHandler: { error in
                if error == nil {
                    let hashDigest = hasher.finalize()
                    let hashString = hashDigest.compactMap { String(format: "%02x", $0) }.joined()
                    continuation.resume(returning: hashString)
                } else {
                    continuation.resume(returning: nil)
                }
            })
        }
    }
    
    public func clearCache() {
        hashCache.removeAll()
    }
}
