import Foundation
import Photos
import UIKit

public actor PerceptualHashService {
    
    public init() {}
    
    public func generateDHash(for asset: PHAsset) async throws -> UInt64 {
        return try await withCheckedThrowingContinuation { continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = .fastFormat
            options.resizeMode = .fast
            options.isNetworkAccessAllowed = true
            options.isSynchronous = false
            
            // 9 width by 8 height gives us 8 adjacent comparisons per row * 8 rows = 64 bits
            let targetSize = CGSize(width: 9, height: 8)
            
            PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { image, info in
                if let error = info?[PHImageErrorKey] as? Error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let image = image else {
                    continuation.resume(throwing: NSError(domain: "PerceptualHashService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to load image"]))
                    return
                }
                
                // Normalizing orientation and drawing into an 9x8 grayscale context
                let hash = self.computeDHash(from: image)
                continuation.resume(returning: hash)
            }
        }
    }
    
    // Internal testable dHash computation
    nonisolated func computeDHash(from image: UIImage) -> UInt64 {
        let size = CGSize(width: 9, height: 8)
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        
        // This natively handles orientation since UIImage.draw correctly applies imageOrientation
        image.draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = normalizedImage?.cgImage else { return 0 }
        
        let width = cgImage.width
        let height = cgImage.height
        
        var pixelData = [UInt8](repeating: 0, count: width * height)
        let colorSpace = CGColorSpaceCreateDeviceGray()
        guard let context = CGContext(data: &pixelData,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: width,
                                      space: colorSpace,
                                      bitmapInfo: CGImageAlphaInfo.none.rawValue) else {
            return 0
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        var hash: UInt64 = 0
        var bitIndex = 0
        
        for y in 0..<height {
            for x in 0..<(width - 1) {
                let leftPixel = pixelData[y * width + x]
                let rightPixel = pixelData[y * width + x + 1]
                
                if leftPixel < rightPixel {
                    hash |= (1 << bitIndex)
                }
                bitIndex += 1
            }
        }
        
        return hash
    }
}
