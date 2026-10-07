import Foundation
import Photos
import Vision
import UIKit

public struct VisionFeatureResult {
    public let data: Data
    public let elementType: Int
    public let elementCount: Int
    public let revision: Int
}

public actor VisionFeatureService {
    
    public init() {}
    
    public func generateVisionFeature(for asset: PHAsset) async throws -> VisionFeatureResult {
        return try await withCheckedThrowingContinuation { continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.resizeMode = .fast
            options.isNetworkAccessAllowed = true
            options.isSynchronous = false
            
            // Vision ML models typically ingest at around 299x299.
            // Using 300x300 keeps us well within the input scale, saving RAM.
            let targetSize = CGSize(width: 300, height: 300)
            
            PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options) { image, info in
                if let error = info?[PHImageErrorKey] as? Error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let image = image else {
                    continuation.resume(throwing: NSError(domain: "VisionFeatureService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to load image for Vision"] ))
                    return
                }
                
                // Fix orientation using CIImage which retains metadata or drawing
                // VNImageRequestHandler accepts orientation natively if provided, but UIImage.cgImage strips orientation.
                // It is safer to draw the UIImage to strip orientation metadata while physically rotating the pixels.
                
                UIGraphicsBeginImageContextWithOptions(image.size, false, 1.0)
                image.draw(in: CGRect(origin: .zero, size: image.size))
                let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                guard let cgImage = normalizedImage?.cgImage else {
                    continuation.resume(throwing: NSError(domain: "VisionFeatureService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Failed to normalize image"]))
                    return
                }
                
                let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                let request = VNGenerateImageFeaturePrintRequest()
                
                // Force specific revision if needed, but let's default to latest
                request.revision = SimilarityConfiguration.shared.currentVisionRevision
                
                do {
                    try requestHandler.perform([request])
                    guard let result = request.results?.first as? VNFeaturePrintObservation else {
                        throw NSError(domain: "VisionFeatureService", code: -3, userInfo: [NSLocalizedDescriptionKey: "No feature print generated"])
                    }
                    
                    let data = try NSKeyedArchiver.archivedData(withRootObject: result, requiringSecureCoding: true)
                    
                    let visionResult = VisionFeatureResult(
                        data: data,
                        elementType: Int(result.elementType.rawValue),
                        elementCount: result.elementCount,
                        revision: request.revision
                    )
                    
                    continuation.resume(returning: visionResult)
                    
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
