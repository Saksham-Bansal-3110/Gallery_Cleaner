//
//  ScreenshotScanner.swift
//  Gallery Cleaner
//

import Foundation
import Photos

public protocol ScreenshotScanning {
    func scanScreenshots(from items: [MediaItem]) -> [MediaItem]
}

public class ScreenshotScanner: ScreenshotScanning {
    public init() {}
    
    public func scanScreenshots(from items: [MediaItem]) -> [MediaItem] {
        return items
            .filter { $0.asset.mediaSubtypes.contains(.photoScreenshot) }
            .sorted { ($0.creationDate ?? Date.distantPast) > ($1.creationDate ?? Date.distantPast) }
    }
}
