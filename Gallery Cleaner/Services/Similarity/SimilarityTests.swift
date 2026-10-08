import Foundation

public struct SimilarityTests {
    public static func runAll() async {
        print("Starting SimilarityTests...")
        testCandidateGenerator()
        testClustererCaseABC()
        testClustererCaseSplit()
        testClustererMissingEdgeABC()
        testThresholds()
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
    
    private static func testThresholds() {
        let clusterer = SimilarityClusterer()
        
        let testCases: [(Float, Bool)] = [
            (0.5, true),
            (1.0, true),
            (1.9, true),
            (2.49, true),
            (2.5, false),
            (3.0, false),
            (5.0, false),
            (10.0, false)
        ]
        
        for (idx, test) in testCases.enumerated() {
            let distance = test.0
            let expectedSimilar = test.1
            
            let id1 = "A\\(idx)"
            let id2 = "B\\(idx)"
            
            let scores = [
                SimilarityScore(firstID: id1, secondID: id2, distance: distance, reasons: [.temporal])
            ]
            let groups = clusterer.cluster(scores: scores)
            
            if expectedSimilar {
                assert(groups.count == 1 && groups[0].count == 2, "Distance \\(distance) should be grouped as similar")
            } else {
                assert(groups.isEmpty || (groups.count == 1 && groups[0].count < 2), "Distance \\(distance) should NOT be grouped")
            }
        }
    }
}
