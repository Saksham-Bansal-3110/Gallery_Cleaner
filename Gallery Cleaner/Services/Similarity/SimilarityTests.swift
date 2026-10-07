import Foundation

public struct SimilarityTests {
    public static func runAll() async {
        print("Starting SimilarityTests...")
        testCandidateGenerator()
        testClustererCaseABC()
        testClustererCaseSplit()
        testClustererMissingEdgeABC()
        print("Completed SimilarityTests.")
    }
    
    private static func testCandidateGenerator() {
        let pair1 = CandidatePair(id1: "A", id2: "B", reason: .temporal)
        let pair2 = CandidatePair(id1: "B", id2: "A", reason: .dHash)
        
        assert(pair1 == pair2, "CandidatePair A/B must equal B/A")
        assert(pair1.hashValue == pair2.hashValue, "Hash values must match")
    }
    
    private static func testClustererCaseABC() {
        let clusterer = SimilarityClusterer()
        let scores = [
            SimilarityScore(firstID: "A", secondID: "B", distance: 2.0, reasons: [.temporal]),
            SimilarityScore(firstID: "B", secondID: "C", distance: 2.0, reasons: [.temporal]),
            SimilarityScore(firstID: "A", secondID: "C", distance: 2.0, reasons: [.temporal])
        ]
        let groups = clusterer.cluster(scores: scores)
        assert(groups.count == 1)
        assert(groups[0].count == 3)
    }
    
    private static func testClustererCaseSplit() {
        let clusterer = SimilarityClusterer()
        let scores = [
            SimilarityScore(firstID: "A", secondID: "B", distance: 2.0, reasons: [.temporal]),
            SimilarityScore(firstID: "B", secondID: "C", distance: 2.0, reasons: [.temporal]),
            SimilarityScore(firstID: "A", secondID: "C", distance: 20.0, reasons: [.temporal])
        ]
        let groups = clusterer.cluster(scores: scores)
        assert(groups.count <= 1)
        if let g = groups.first {
            assert(g.count == 2)
        }
    }
    
    private static func testClustererMissingEdgeABC() {
        let clusterer = SimilarityClusterer()
        let scores = [
            SimilarityScore(firstID: "A", secondID: "B", distance: 2.0, reasons: [.temporal]),
            SimilarityScore(firstID: "B", secondID: "C", distance: 2.0, reasons: [.temporal])
        ]
        let groups = clusterer.cluster(scores: scores)
        assert(groups.count <= 1)
        if let g = groups.first {
            assert(g.count == 2)
        }
    }
}
