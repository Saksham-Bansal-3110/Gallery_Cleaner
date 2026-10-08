import Foundation

public class SimilarityClustererDiagnostics {
    public var totalGroups: Int = 0
    public var groupSizes: [Int: Int] = [:] // size -> count
    public var maxGroupSize: Int = 0
    public var averageGroupSize: Float = 0
    public var totalGroupedPhotos: Int = 0
    public var rejectedMerges: Int = 0
    
    public init(
        totalGroups: Int = 0,
        groupSizes: [Int: Int] = [:],
        maxGroupSize: Int = 0,
        averageGroupSize: Float = 0,
        totalGroupedPhotos: Int = 0,
        rejectedMerges: Int = 0
    ) {
        self.totalGroups = totalGroups
        self.groupSizes = groupSizes
        self.maxGroupSize = maxGroupSize
        self.averageGroupSize = averageGroupSize
        self.totalGroupedPhotos = totalGroupedPhotos
        self.rejectedMerges = rejectedMerges
    }
    
    func record(groups: [[String]]) {
        totalGroups = groups.count
        var totalSize = 0
        for g in groups {
            let size = g.count
            groupSizes[size, default: 0] += 1
            maxGroupSize = max(maxGroupSize, size)
            totalSize += size
        }
        totalGroupedPhotos = totalSize
        averageGroupSize = totalGroups > 0 ? Float(totalSize) / Float(totalGroups) : 0
    }
}

public class SimilarityClusterer {
    
    public var diagnostics = SimilarityClustererDiagnostics()
    public init() {}
    
    public func cluster(scores: [SimilarityScore]) -> [[String]] {
        let maxIntraGroupDistance = SimilarityConfiguration.shared.strongSimilarityThreshold
        
        // Filter edges by high confidence threshold immediately
        let validScores = scores.filter { $0.distance < maxIntraGroupDistance }
            .sorted { $0.distance < $1.distance }
        
        var clusters: [[String]] = []
        var itemToClusterIndex: [String: Int] = [:]
        
        // Dictionary for O(1) edge lookups to validate complete-linkage
        var distanceMap: [String: [String: Float]] = [:]
        for score in scores { // use all scores to check distances between clusters
            distanceMap[score.firstID, default: [:]][score.secondID] = score.distance
            distanceMap[score.secondID, default: [:]][score.firstID] = score.distance
            // Identity
            distanceMap[score.firstID, default: [:]][score.firstID] = 0
            distanceMap[score.secondID, default: [:]][score.secondID] = 0
        }
        
        func distance(between id1: String, and id2: String) -> Float {
            return distanceMap[id1]?[id2] ?? .infinity
        }
        
        for edge in validScores {
            let u = edge.firstID
            let v = edge.secondID
            
            let clusterIdxU = itemToClusterIndex[u]
            let clusterIdxV = itemToClusterIndex[v]
            
            if clusterIdxU == nil && clusterIdxV == nil {
                // New cluster
                let newIndex = clusters.count
                clusters.append([u, v])
                itemToClusterIndex[u] = newIndex
                itemToClusterIndex[v] = newIndex
                
            } else if let cU = clusterIdxU, clusterIdxV == nil {
                // Try adding v to cluster U
                let clusterNodes = clusters[cU]
                var canJoin = true
                for node in clusterNodes {
                    if distance(between: node, and: v) >= maxIntraGroupDistance {
                        canJoin = false
                        break
                    }
                }
                if canJoin {
                    clusters[cU].append(v)
                    itemToClusterIndex[v] = cU
                }
                
            } else if let cV = clusterIdxV, clusterIdxU == nil {
                // Try adding u to cluster V
                let clusterNodes = clusters[cV]
                var canJoin = true
                for node in clusterNodes {
                    if distance(between: node, and: u) >= maxIntraGroupDistance {
                        canJoin = false
                        break
                    }
                }
                if canJoin {
                    clusters[cV].append(u)
                    itemToClusterIndex[u] = cV
                }
                
            } else if let cU = clusterIdxU, let cV = clusterIdxV, cU != cV {
                // Try merging U and V
                let nodesU = clusters[cU]
                let nodesV = clusters[cV]
                
                var canMerge = true
                for nU in nodesU {
                    for nV in nodesV {
                        if distance(between: nU, and: nV) >= maxIntraGroupDistance {
                            canMerge = false
                            break
                        }
                    }
                                        if !canMerge { 
                        diagnostics.rejectedMerges += 1
                        break 
                    }
                }
                
                if canMerge {
                    clusters[cU].append(contentsOf: nodesV)
                    for nV in nodesV {
                        itemToClusterIndex[nV] = cU
                    }
                    clusters[cV] = [] // clear out merged cluster
                }
            }
        }
        
                let result = clusters.filter { $0.count >= 2 }
        diagnostics.record(groups: result)
        
        #if DEBUG
        print("--- SIMILARITY CLUSTERER DIAGNOSTICS ---")
        print("Total Groups: \(diagnostics.totalGroups)")
        print("Rejected Merges (Missing Edges or Too Far): \(diagnostics.rejectedMerges)")
        print("Total Photos Grouped: \(diagnostics.totalGroupedPhotos)")
        print(String(format: "Average Group Size: %.2f", diagnostics.averageGroupSize))
        print("Max Group Size: \(diagnostics.maxGroupSize)")
        print("Size Distribution: \(diagnostics.groupSizes)")
        print("----------------------------------------")
        #endif
        
        return result
    }
}
