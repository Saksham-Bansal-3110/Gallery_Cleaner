import Foundation
let path = "./Gallery Cleaner/App/GalleryCleanerApp.swift"
var content = try! String(contentsOfFile: path)
content = content.replacingOccurrences(of: """
            Task { @MainActor in
                PhotoAnalysisCache.shared.configure(with: tempContainer)
            }
""", with: "")
try! content.write(toFile: path, atomically: true, encoding: .utf8)
