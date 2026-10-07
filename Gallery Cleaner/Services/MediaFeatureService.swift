//
//  MediaFeatureService.swift
//  Gallery Cleaner
//

import Foundation
import Photos
import Vision
import UIKit

public actor MediaFeatureService {
    public static let shared = MediaFeatureService()
    
    private var featureCache: [String: VNFeaturePrintObservation] = [:]
    
    private init() {}
    
    public func getFeaturePrint(for asset: PHAsset) async -> VNFeaturePrintObservation? {
        if let cached = featureCache[asset.localIdentifier] {
            return cached
        }
        
        let observation = await computeFeaturePrint(for: asset)
        if let observation = observation {
            featureCache[asset.localIdentifier] = observation
        }
        return observation
    }
    
    private func computeFeaturePrint(for asset: PHAsset) async -> VNFeaturePrintObservation? {
        return await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat // Ensures it only calls completion once asynchronously
            options.resizeMode = .fast
            options.isNetworkAccessAllowed = true
            options.isSynchronous = false
            
            // Extract a thumbnail appropriate for Vision processing
            PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 300, height: 300), contentMode: .aspectFit, options: options) { image, info in
                guard let cgImage = image?.cgImage else {
                    #if DEBUG
                    let error = info?[PHImageErrorKey] as? Error
                    print("MediaFeatureService: Failed to fetch thumbnail for asset \(asset.localIdentifier): \(error?.localizedDescription ?? "Unknown error")")
                    #endif
                    continuation.resume(returning: nil)
                    return
                }
                
                // Execute Vision request
                let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                let request = VNGenerateImageFeaturePrintRequest()
                
                do {
                    try requestHandler.perform([request])
                    if let result = request.results?.first as? VNFeaturePrintObservation {
                        continuation.resume(returning: result)
                    } else {
                        #if DEBUG
                        print("MediaFeatureService: No feature print found for asset \(asset.localIdentifier)")
                        #endif
                        continuation.resume(returning: nil)
                    }
                } catch {
                    #if DEBUG
                    print("MediaFeatureService: Vision request failed for asset \(asset.localIdentifier): \(error.localizedDescription)")
                    #endif
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
    public func clearCache() {
        featureCache.removeAll()
    }
}
