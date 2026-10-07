import Foundation

let path = "Gallery Cleaner/Services/Similarity/SimilarityClusterer.swift"
var content = try! String(contentsOfFile: path)

let header = """
import Foundation

public class SimilarityClustererDiagnostics {
    public var totalGroups: Int = 0
    public var groupSizes: [Int: Int] = [:] // size -> count
    public var maxGroupSize: Int = 0
    public var averageGroupSize: Float = 0
    public var totalGroupedPhotos: Int = 0
    public var rejectedMerges: Int = 0
    
    public init() {}
    
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
"""

content = content.replacingOccurrences(of: "import Foundation", with: header)

content = content.replacingOccurrences(of: """
    public init() {}
""", with: """
    public var diagnostics = SimilarityClustererDiagnostics()
    public init() {}
""")

let rejectedInjections = """
                    if !canMerge { 
                        diagnostics.rejectedMerges += 1
                        break 
                    }
"""

content = content.replacingOccurrences(of: "if !canMerge { break }", with: rejectedInjections)

let footer = """
        let result = clusters.filter { $0.count >= 2 }
        diagnostics.record(groups: result)
        
        #if DEBUG
        print("--- SIMILARITY CLUSTERER DIAGNOSTICS ---")
        print("Total Groups: \\(diagnostics.totalGroups)")
        print("Rejected Merges (Missing Edges or Too Far): \\(diagnostics.rejectedMerges)")
        print("Total Photos Grouped: \\(diagnostics.totalGroupedPhotos)")
        print(String(format: "Average Group Size: %.2f", diagnostics.averageGroupSize))
        print("Max Group Size: \\(diagnostics.maxGroupSize)")
        print("Size Distribution: \\(diagnostics.groupSizes)")
        print("----------------------------------------")
        #endif
        
        return result
"""

content = content.replacingOccurrences(of: "return clusters.filter { $0.count >= 2 }", with: footer)

try! content.write(toFile: path, atomically: true, encoding: .utf8)
