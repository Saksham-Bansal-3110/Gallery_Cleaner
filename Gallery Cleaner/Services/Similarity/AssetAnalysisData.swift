import Foundation
import SwiftData

public struct PhotoAnalysisResult {
    public let localIdentifier: String
    public let modificationDate: Date
    public let pixelWidth: Int
    public let pixelHeight: Int
    public let aspectRatio: Float
    public let perceptualHash: UInt64
    public let visionFeatureData: Data
    public let visionElementType: Int
    public let visionElementCount: Int
    public let visionRevision: Int
}

@Model
public final class AssetAnalysisData {
    @Attribute(.unique) public var localIdentifier: String
    public var modificationDate: Date
    public var pixelWidth: Int
    public var pixelHeight: Int
    public var aspectRatio: Float
    public var perceptualHash: UInt64
    public var visionFeatureData: Data
    public var visionElementType: Int
    public var visionElementCount: Int
    public var visionRevision: Int
    public var algorithmVersion: Int
    
    public init(result: PhotoAnalysisResult, algorithmVersion: Int) {
        self.localIdentifier = result.localIdentifier
        self.modificationDate = result.modificationDate
        self.pixelWidth = result.pixelWidth
        self.pixelHeight = result.pixelHeight
        self.aspectRatio = result.aspectRatio
        self.perceptualHash = result.perceptualHash
        self.visionFeatureData = result.visionFeatureData
        self.visionElementType = result.visionElementType
        self.visionElementCount = result.visionElementCount
        self.visionRevision = result.visionRevision
        self.algorithmVersion = algorithmVersion
    }
    
    public func toResult() -> PhotoAnalysisResult {
        PhotoAnalysisResult(
            localIdentifier: localIdentifier,
            modificationDate: modificationDate,
            pixelWidth: pixelWidth,
            pixelHeight: pixelHeight,
            aspectRatio: aspectRatio,
            perceptualHash: perceptualHash,
            visionFeatureData: visionFeatureData,
            visionElementType: visionElementType,
            visionElementCount: visionElementCount,
            visionRevision: visionRevision
        )
    }
}
