import Foundation
let path = "Gallery Cleaner/ViewModels/GalleryViewModel.swift"
var content = try! String(contentsOfFile: path)
content = content.replacingOccurrences(of: """
                self.similarPhotos = await similarScanner.scanSimilarPhotos(from: items)
""", with: """
                let exactIDs = Set(self.duplicatePhotos.flatMap { $0.items }.map { $0.id })
                self.similarPhotos = await similarScanner.scanSimilarPhotos(from: items, exactDuplicateIDs: exactIDs)
""")
content = content.replacingOccurrences(of: """
        self.similarPhotos = await similarScanner.scanSimilarPhotos(from: allItems)
""", with: """
        let exactIDs = Set(self.duplicatePhotos.flatMap { $0.items }.map { $0.id })
        self.similarPhotos = await similarScanner.scanSimilarPhotos(from: allItems, exactDuplicateIDs: exactIDs)
""")
try! content.write(toFile: path, atomically: true, encoding: .utf8)
