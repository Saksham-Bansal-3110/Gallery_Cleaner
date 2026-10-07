//
//  SimilarPhotoScanner.swift
//  Gallery Cleaner
//

import Foundation
import Photos
import Vision

public protocol SimilarPhotoScanning {
    func scanSimilarPhotos(from items: [MediaItem]) async -> [DuplicateGroup]
}

public class SimilarPhotoScanner: SimilarPhotoScanning {
    // Tuning threshold: lower means more similar. VNFeaturePrintObservation distance is usually > 0.
    // A threshold of ~10.0 to 15.0 is typical for visually similar images.
    public let similarityThreshold: Float = 12.0
    // Time constraint to avoid N^2 comparisons across the entire library
    public let maxTimeDifference: TimeInterval = 24 * 60 * 60 // 24 hours
    
    public init() {}
    
    public func scanSimilarPhotos(from items: [MediaItem]) async -> [DuplicateGroup] {
        let photos = items.filter { $0.mediaType == .image }.sorted { ($0.creationDate ?? Date.distantPast) > ($1.creationDate ?? Date.distantPast) }
        
        guard !photos.isEmpty else { return [] }
        
        // 1. Fetch all feature prints in parallel using a TaskGroup
        var featurePrints: [String: VNFeaturePrintObservation] = [:]
        await withTaskGroup(of: (String, VNFeaturePrintObservation?).self) { group in
            let maxConcurrentTasks = 10
            var i = 0
            
            while i < min(maxConcurrentTasks, photos.count) {
                let photo = photos[i]
                group.addTask {
                    let print = await MediaFeatureService.shared.getFeaturePrint(for: photo.asset)
                    return (photo.id, print)
                }
                i += 1
            }
            
            for await (id, print) in group {
                if let print = print {
                    featurePrints[id] = print
                }
                
                if i < photos.count {
                    let photo = photos[i]
                    group.addTask {
                        let print = await MediaFeatureService.shared.getFeaturePrint(for: photo.asset)
                        return (photo.id, print)
                    }
                    i += 1
                }
            }
        }
        
        // 2. Group visually similar photos using a sliding window
        var processedIDs = Set<String>()
        var similarGroups: [DuplicateGroup] = []
        var groupIndex = 1
        
        for i in 0..<photos.count {
            let basePhoto = photos[i]
            guard !processedIDs.contains(basePhoto.id), let basePrint = featurePrints[basePhoto.id] else { continue }
            
            var currentGroupItems = [basePhoto]
            processedIDs.insert(basePhoto.id)
            
            // Compare with subsequent photos
            for j in (i+1)..<photos.count {
                let candidatePhoto = photos[j]
                if processedIDs.contains(candidatePhoto.id) { continue }
                
                // Time heuristic: break early since array is sorted by date
                if let baseDate = basePhoto.creationDate, let candidateDate = candidatePhoto.creationDate {
                    if abs(baseDate.timeIntervalSince(candidateDate)) > maxTimeDifference {
                        break 
                    }
                }
                
                if let candidatePrint = featurePrints[candidatePhoto.id] {
                    var distance: Float = 0
                    do {
                        try basePrint.computeDistance(&distance, to: candidatePrint)
                        if distance < similarityThreshold {
                            currentGroupItems.append(candidatePhoto)
                            processedIDs.insert(candidatePhoto.id)
                        }
                    } catch {
                        // ignore error
                    }
                }
            }
            
            if currentGroupItems.count > 1 {
                var title = "Similar \(groupIndex)"
                if let firstAsset = currentGroupItems.first?.asset {
                    let resources = PHAssetResource.assetResources(for: firstAsset)
                    if let filename = resources.first?.originalFilename {
                        title = filename + " (Similar)"
                    }
                }
                
                similarGroups.append(DuplicateGroup(id: UUID().uuidString, title: title, items: currentGroupItems))
                groupIndex += 1
            }
        }
        
        return similarGroups
    }
}
