//
//  VideoScanner.swift
//  Gallery Cleaner
//

import Foundation
import Photos

public protocol VideoScanning {
    func scanVideos(from items: [MediaItem]) -> [MediaItem]
}

public class VideoScanner: VideoScanning {
    public init() {}
    
    public func scanVideos(from items: [MediaItem]) -> [MediaItem] {
        return items
            .filter { $0.mediaType == .video }
            .sorted { ($0.creationDate ?? Date.distantPast) > ($1.creationDate ?? Date.distantPast) }
    }
}
