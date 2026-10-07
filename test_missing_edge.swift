import Foundation

let path = "Gallery Cleaner/Services/Similarity/SimilarityTests.swift"
var content = try! String(contentsOfFile: path)
let target = "testClustererCaseSplit()"
let replacement = """
testClustererCaseSplit()
testClustererMissingEdgeABC()
"""
content = content.replacingOccurrences(of: target, with: replacement)

let target2 = "private static func testClustererCaseSplit() {"
let replacement2 = """
    private static func testClustererMissingEdgeABC() {
        let clusterer = SimilarityClusterer()
        let scores = [
            SimilarityScore(firstID: "A", secondID: "B", distance: 2.0, reasons: [.temporal]),
            SimilarityScore(firstID: "B", secondID: "C", distance: 2.0, reasons: [.temporal])
            // A~C edge is entirely missing!
        ]
        let groups = clusterer.cluster(scores: scores)
        assert(groups.count <= 1, "Should not group ABC together")
        if let g = groups.first {
            assert(g.count == 2, "Cannot form [A,B,C] without A~C score")
        }
        print("Clusterer Case 3 (Missing Edge Rejection) passed.")
    }

    private static func testClustererCaseSplit() {
"""
content = content.replacingOccurrences(of: target2, with: replacement2)

// Also fix existing test scores missing reasons:
content = content.replacingOccurrences(of: ", distance: 2.0)", with: ", distance: 2.0, reasons: [.temporal])")
content = content.replacingOccurrences(of: ", distance: 20.0)", with: ", distance: 20.0, reasons: [.temporal])")

try! content.write(toFile: path, atomically: true, encoding: .utf8)
