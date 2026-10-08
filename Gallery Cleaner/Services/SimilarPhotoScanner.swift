import Foundation
import Photos
import SwiftData

public protocol SimilarPhotoScanning {
    func scanSimilarPhotos(from items: [MediaItem], exactDuplicateIDs: Set<String>) async -> [DuplicateGroup]
}

public class SimilarPhotoScanner: SimilarPhotoScanning {
    
    public init() {}
    
    public func scanSimilarPhotos(from items: [MediaItem], exactDuplicateIDs: Set<String> = []) async -> [DuplicateGroup] {
        let photos = items.filter { $0.mediaType == .image }
        guard !photos.isEmpty else { return [] }
        
        let assets = photos.map { $0.asset }
        
        // STAGE 2: Analysis & Feature Extraction
        // Needs cache instance. We assume we can create an ephemeral SwiftData container if we don't have the main one, 
        // or we just inject it. But for now, we'll try to instantiate a temporary one safely if not injected.
        let container: ModelContainer
        do {
            container = try ModelContainer(for: AssetAnalysisData.self)
        } catch {
            print("SimilarPhotoScanner: Failed to create SwiftData container. Fallback to empty groups.")
            return []
        }
        
        let cache = PhotoAnalysisCache(modelContainer: container)
        let analysisService = PhotoAnalysisService(cache: cache)
        
        let analyses = await analysisService.analyze(assets: assets)
        
        // STAGE 3: Candidates, Scoring, Clustering
        let candidateGenerator = CandidateGenerator()
        let pairs = candidateGenerator.generateCandidates(items: photos, analyses: analyses, exactDuplicateIDs: exactDuplicateIDs)
        
        let scorer = SimilarityScorer()
        let scores = await scorer.score(pairs: pairs, analyses: analyses)
        
        let clusterer = SimilarityClusterer()
        let clusters = clusterer.cluster(scores: scores)
        
        // STAGE 4: Ranking & Output
        let rankingService = PhotoRankingService()
        
        let itemDict = Dictionary(uniqueKeysWithValues: photos.map { ($0.id, $0) })
        var similarGroups = [DuplicateGroup]()
        
        for (index, clusterIDs) in clusters.enumerated() {
            let groupItems = clusterIDs.compactMap { itemDict[$0] }
            if groupItems.count >= 2 {
                // Determine group title
                var title = "Similar \\(index + 1)"
                if let first = groupItems.first?.filename {
                    title = first + " (Similar)"
                }
                
                let rankingResult = await rankingService.rank(items: groupItems)
                
                let group = DuplicateGroup(
                    id: UUID().uuidString,
                    title: title,
                    items: groupItems,
                    recommendedItem: rankingResult.recommended,
                    rankedItems: rankingResult.rankedItems
                )
                similarGroups.append(group)
            }
        }
        
                let sortedGroups = similarGroups
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
