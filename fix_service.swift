import Foundation
let path = "Gallery Cleaner/Services/Similarity/PhotoAnalysisService.swift"
var content = try! String(contentsOfFile: path)
content = content.replacingOccurrences(of: """
    private let perceptualService = PerceptualHashService()
    private let visionService = VisionFeatureService()
""", with: """
    private let cache: PhotoAnalysisCache
    private let perceptualService = PerceptualHashService()
    private let visionService = VisionFeatureService()
""")
content = content.replacingOccurrences(of: """
    public init() {}
""", with: """
    public init(cache: PhotoAnalysisCache) {
        self.cache = cache
    }
""")
content = content.replacingOccurrences(of: "PhotoAnalysisCache.shared", with: "cache")
try! content.write(toFile: path, atomically: true, encoding: .utf8)
