import Foundation

let path = "Gallery Cleaner/Services/SimilarPhotoScanner.swift"
var content = try! String(contentsOfFile: path)
content = content.replacingOccurrences(of: """
public protocol SimilarPhotoScanning {
    func scanSimilarPhotos(from items: [MediaItem]) async -> [DuplicateGroup]
}
""", with: """
public protocol SimilarPhotoScanning {
    func scanSimilarPhotos(from items: [MediaItem], exactDuplicateIDs: Set<String>) async -> [DuplicateGroup]
}
""")
try! content.write(toFile: path, atomically: true, encoding: .utf8)
