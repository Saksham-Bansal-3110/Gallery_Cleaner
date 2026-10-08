//
//  DuplicatePhotoScanner.swift
//  Gallery Cleaner
//

import Foundation
import Photos
import CryptoKit

public protocol DuplicatePhotoScanning {
    func scanDuplicates(from items: [MediaItem]) async -> [DuplicateGroup]
}

public class DuplicatePhotoScanner: DuplicatePhotoScanning {
    public init() {}
    
    public func scanDuplicates(from items: [MediaItem]) async -> [DuplicateGroup] {
        let photos = items.filter { $0.mediaType == .image }
        
        // We will process them in parallel with a task group for performance
        var hashes: [String: [MediaItem]] = [:]
        
        await withTaskGroup(of: (MediaItem, String?).self) { group in
            let maxConcurrentTasks = 20
            var i = 0
            
            while i < min(maxConcurrentTasks, photos.count) {
                let item = photos[i]
                group.addTask {
                    let hash = await MediaHashService.shared.getHash(for: item.asset)
                    return (item, hash)
                }
                i += 1
            }
            
            for await (item, hash) in group {
                if let hash = hash {
                    hashes[hash, default: []].append(item)
                }
                
                if i < photos.count {
                    let item = photos[i]
                    group.addTask {
                        let hash = await MediaHashService.shared.getHash(for: item.asset)
                        return (item, hash)
                    }
                    i += 1
                }
            }
        }
        
        var duplicateGroups: [DuplicateGroup] = []
        var groupIndex = 1
        
        for (hash, groupItems) in hashes where groupItems.count > 1 {
            let sortedItems = groupItems.sorted { ($0.creationDate ?? Date.distantPast) > ($1.creationDate ?? Date.distantPast) }
            
            // Try to extract a title from the original filename if possible, otherwise use a generic name
            var title = "Group \(groupIndex)"
            if let firstAsset = sortedItems.first?.asset {
                let resources = PHAssetResource.assetResources(for: firstAsset)
                if let filename = resources.first?.filename {
                    title = filename
                }
            }
            
            duplicateGroups.append(DuplicateGroup(id: hash, title: title, items: sortedItems))
            groupIndex += 1
        }
        
        // Sort groups by total size or by date of the first item
                let sortedGroups = duplicateGroups.sorted { ($0.items.first?.creationDate ?? Date.distantPast) > ($1.items.first?.creationDate ?? Date.distantPast) }
        return sortedGroups.enumerated().map { index, group in
            DuplicateGroup(
                id: group.id,
                title: "Group \(index + 1)",
                items: group.items,
                recommendedItem: group.recommendedItem,
                rankedItems: group.rankedItems
            )
        }
    }
}
