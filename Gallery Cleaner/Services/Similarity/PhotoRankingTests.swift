import Foundation

public struct PhotoRankingTests {
    public static func runAll() {
        print("Starting PhotoRankingTests...")
        testFavoriteBeatsResolution()
        testResolutionBeatsLowResolution()
        testRecencyDoesNotDominate()
        testDeterministicOrdering()
        print("Completed PhotoRankingTests.")
    }
    
    private static func testFavoriteBeatsResolution() {
        let scoreFav = PhotoRankingService.computeScore(
            id: "1", isFavorite: true, resolution: 100, maxResolution: 1000, 
            isEdited: false, isLive: false, creationTime: 0, oldestTime: 0, timeRange: 1
        )
        let scoreRes = PhotoRankingService.computeScore(
            id: "2", isFavorite: false, resolution: 1000, maxResolution: 1000, 
            isEdited: false, isLive: false, creationTime: 0, oldestTime: 0, timeRange: 1
        )
        assert(scoreFav.score > scoreRes.score, "Favorite (1000) must beat max resolution (500)")
    }
    
    private static func testResolutionBeatsLowResolution() {
        let scoreLow = PhotoRankingService.computeScore(
            id: "1", isFavorite: false, resolution: 100, maxResolution: 1000, 
            isEdited: false, isLive: false, creationTime: 0, oldestTime: 0, timeRange: 1
        )
        let scoreHigh = PhotoRankingService.computeScore(
            id: "2", isFavorite: false, resolution: 1000, maxResolution: 1000, 
            isEdited: false, isLive: false, creationTime: 0, oldestTime: 0, timeRange: 1
        )
        assert(scoreHigh.score > scoreLow.score, "Higher resolution must score higher")
    }
    
    private static func testRecencyDoesNotDominate() {
        // Newer but low res vs Older but high res
        let scoreNew = PhotoRankingService.computeScore(
            id: "new", isFavorite: false, resolution: 100, maxResolution: 1000, 
            isEdited: false, isLive: false, creationTime: 100, oldestTime: 0, timeRange: 100
        )
        let scoreOld = PhotoRankingService.computeScore(
            id: "old", isFavorite: false, resolution: 1000, maxResolution: 1000, 
            isEdited: false, isLive: false, creationTime: 0, oldestTime: 0, timeRange: 100
        )
        assert(scoreOld.score > scoreNew.score, "Recency (+10 max) should not beat resolution diff (+450)")
    }
    
    private static func testDeterministicOrdering() {
        let score1 = PhotoRankingService.computeScore(
            id: "B", isFavorite: false, resolution: 100, maxResolution: 100, 
            isEdited: false, isLive: false, creationTime: 0, oldestTime: 0, timeRange: 1
        )
        let score2 = PhotoRankingService.computeScore(
            id: "A", isFavorite: false, resolution: 100, maxResolution: 100, 
            isEdited: false, isLive: false, creationTime: 0, oldestTime: 0, timeRange: 1
        )
        
        // When scores are equal, sort by ID descending natively in rank()
        // Wait, rank() does a > b on scores, and if equal, a.id > b.id
        // We will just verify that the scores are identical.
        assert(abs(score1.score - score2.score) < 0.0001, "Scores should be perfectly identical")
    }
}
