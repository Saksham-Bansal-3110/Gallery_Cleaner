import Foundation
import Photos
import SwiftUI

class MockPHAsset: PHAsset, @unchecked Sendable {
    var mockCreationDate: Date?
    var mockLocalIdentifier: String
    
    init(localIdentifier: String, creationDate: Date?) {
        self.mockLocalIdentifier = localIdentifier
        self.mockCreationDate = creationDate
        super.init()
    }
    
    override var localIdentifier: String { return mockLocalIdentifier }
    override var creationDate: Date? { return mockCreationDate }
    override var mediaType: PHAssetMediaType { return .image }
}

@MainActor
public struct CategorySortTests {
    public static func runAll() {
        print("Running Category Sort Tests...")
        testMediaItemSort()
        print("Category Sort Tests passed!")
    }
    
    private static func testMediaItemSort() {
        let dateForm = DateFormatter()
        dateForm.dateFormat = "MMM d, yyyy"
        
        let d1 = dateForm.date(from: "Jan 1, 2026")!
        let d3 = dateForm.date(from: "Jan 3, 2026")!
        let d5 = dateForm.date(from: "Jan 5, 2026")!
        
        let assetA = MockPHAsset(localIdentifier: "A", creationDate: d1)
        let assetB = MockPHAsset(localIdentifier: "B", creationDate: d5)
        let assetC = MockPHAsset(localIdentifier: "C", creationDate: d3)
        
        let itemA = MediaItem(asset: assetA, sizeInBytes: 10_000_000)
        let itemB = MediaItem(asset: assetB, sizeInBytes: 50_000_000)
        let itemC = MediaItem(asset: assetC, sizeInBytes: 20_000_000)
        
        let rawItems = [itemA, itemB, itemC]
        
        // Newest First
        let newest = rawItems.sorted { 
            let date1 = $0.creationDate ?? .distantPast
            let date2 = $1.creationDate ?? .distantPast
            if date1 == date2 { return $0.id > $1.id }
            return date1 > date2
        }
        assert(newest.map { $0.id } == ["B", "C", "A"], "Newest sort failed")
        
        // Oldest First
        let oldest = rawItems.sorted { 
            let date1 = $0.creationDate ?? .distantPast
            let date2 = $1.creationDate ?? .distantPast
            if date1 == date2 { return $0.id < $1.id }
            return date1 < date2
        }
        assert(oldest.map { $0.id } == ["A", "C", "B"], "Oldest sort failed")
        
        // Largest First
        let largest = rawItems.sorted { 
            if $0.sizeInBytes == $1.sizeInBytes { return $0.id > $1.id }
            return $0.sizeInBytes > $1.sizeInBytes 
        }
        assert(largest.map { $0.id } == ["B", "C", "A"], "Largest sort failed")
        
        // Smallest First
        let smallest = rawItems.sorted { 
            if $0.sizeInBytes == $1.sizeInBytes { return $0.id < $1.id }
            return $0.sizeInBytes < $1.sizeInBytes 
        }
        assert(smallest.map { $0.id } == ["A", "C", "B"], "Smallest sort failed")
        
        // Default Order
        let defaultOrder = rawItems
        assert(defaultOrder.map { $0.id } == ["A", "B", "C"], "Default sort failed")
    }
}
