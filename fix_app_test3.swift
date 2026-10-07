import Foundation
let path = "./Gallery Cleaner/App/GalleryCleanerApp.swift"
var content = try! String(contentsOfFile: path)
content = content.replacingOccurrences(of: """
                    #if DEBUG
                    await PhotoAnalysisTests.runAll(container: container)
                    #endif
""", with: """
                    #if DEBUG
                    await PhotoAnalysisTests.runAll(container: container)
                    await SimilarityTests.runAll()
                    #endif
""")
try! content.write(toFile: path, atomically: true, encoding: .utf8)
