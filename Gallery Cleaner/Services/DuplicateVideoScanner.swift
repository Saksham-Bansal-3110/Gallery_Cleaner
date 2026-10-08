//
//  DuplicateVideoScanner.swift
//  Gallery Cleaner
//

import Foundation
import Photos

public protocol DuplicateVideoScanning {
    func scanDuplicates(from items: [MediaItem]) async -> [DuplicateGroup]
}

public class DuplicateVideoScanner: DuplicateVideoScanning {
    public init() {}
    
    public func scanDuplicates(from items: [MediaItem]) async -> [DuplicateGroup] {
        let videos = items.filter { $0.mediaType == .video }
        
        // We will process them in parallel with a task group for performance
        var hashes: [String: [MediaItem]] = [:]
        
        await withTaskGroup(of: (MediaItem, String?).self) { group in
            let maxConcurrentTasks = 10 // fewer concurrent for videos
            var i = 0
            
            while i < min(maxConcurrentTasks, videos.count) {
                let item = videos[i]
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
                
                if i < videos.count {
                    let item = videos[i]
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
        
        // Sort groups by date of the first item
        return duplicateGroups.sorted { ($0.items.first?.creationDate ?? Date.distantPast) > ($1.items.first?.creationDate ?? Date.distantPast) }
    }
}
