import Foundation
let path = "./Gallery Cleaner/App/GalleryCleanerApp.swift"
var content = try! String(contentsOfFile: path)
content = content.replacingOccurrences(of: """
                    await SimilarityTests.runAll()
                    #endif
""", with: """
                    await SimilarityTests.runAll()
                    PhotoRankingTests.runAll()
                    #endif
""")
try! content.write(toFile: path, atomically: true, encoding: .utf8)
