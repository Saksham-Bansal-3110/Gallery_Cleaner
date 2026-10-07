//
//  MediaItem.swift
//  Gallery Cleaner
//

import Foundation
import Photos
import UIKit

public struct MediaItem: Identifiable, Hashable {
    public let id: String // mapped to localIdentifier
    public let asset: PHAsset
    public let mediaType: PHAssetMediaType
    public let creationDate: Date?
    public let modificationDate: Date?
    public let pixelWidth: Int
    public let pixelHeight: Int
    public let duration: TimeInterval
    public var sizeInBytes: Int64
    
    public init(asset: PHAsset, sizeInBytes: Int64) {
        self.id = asset.localIdentifier
        self.asset = asset
        self.mediaType = asset.mediaType
        self.creationDate = asset.creationDate
        self.modificationDate = asset.modificationDate
        self.pixelWidth = asset.pixelWidth
        self.pixelHeight = asset.pixelHeight
        self.duration = asset.duration
        self.sizeInBytes = sizeInBytes
    }
    
    public var formattedSize: String {
        guard sizeInBytes > 0 else { return "Unknown" }
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: sizeInBytes)
    }
    
    public var formattedDuration: String? {
        guard mediaType == .video, duration > 0 else { return nil }
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: duration)
    }
    
    public static func == (lhs: MediaItem, rhs: MediaItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
