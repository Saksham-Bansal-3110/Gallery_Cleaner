import Foundation
let path = "./Gallery Cleaner/App/GalleryCleanerApp.swift"
var content = try! String(contentsOfFile: path)
content = content.replacingOccurrences(of: """
        }
        .modelContainer(container)
        .task {
            #if DEBUG
            await PhotoAnalysisTests.runAll()
            #endif
        }
""", with: """
        }
        .modelContainer(container)
""")

let newContent = content.replacingOccurrences(of: """
            HomeView()
                .environmentObject(galleryViewModel)
""", with: """
            HomeView()
                .environmentObject(galleryViewModel)
                .task {
                    #if DEBUG
                    await PhotoAnalysisTests.runAll()
                    #endif
                }
""")
try! newContent.write(toFile: path, atomically: true, encoding: .utf8)
