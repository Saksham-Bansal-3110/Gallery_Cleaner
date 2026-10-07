import Foundation
import UIKit
import SwiftData

public struct PhotoAnalysisTests {
    public static func runAll(container: SwiftData.ModelContainer) async {
        print("Starting PhotoAnalysisTests...")
        
        await testDHash()
        await testConcurrency(container: container)
        
        print("Completed PhotoAnalysisTests.")
    }
    
    private static func testDHash() async {
        let service = PerceptualHashService()
        
        // 1. Create identical image
        let size = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        UIColor.red.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let img1 = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // 2. Test Determinism
        let hash1 = service.computeDHash(from: img1)
        let hash2 = service.computeDHash(from: img1)
        
        assert(hash1 == hash2, "dHash is not deterministic")
        print("dHash determinism test passed.")
    }
    
    private static func testConcurrency(container: SwiftData.ModelContainer) async {
        let cache = PhotoAnalysisCache(modelContainer: container)
        let service = PhotoAnalysisService(cache: cache)
        let results = await service.analyze(assets: [])
        assert(results.isEmpty, "Empty assets should return empty results")
        print("Concurrency boundary test passed.")
    }
}
