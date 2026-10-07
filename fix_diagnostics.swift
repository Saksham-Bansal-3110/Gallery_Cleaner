import Foundation

let path = "Gallery Cleaner/Services/Similarity/SimilarityClusterer.swift"
var content = try! String(contentsOfFile: path)
content = content.replacingOccurrences(of: """
    public var rejectedMerges: Int = 0
    
    public var diagnostics = SimilarityClustererDiagnostics()
    public init() {}
""", with: """
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
""")
try! content.write(toFile: path, atomically: true, encoding: .utf8)
