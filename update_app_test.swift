import Foundation

let path = "./Gallery Cleaner/App/GalleryCleanerApp.swift"
var content = try! String(contentsOfFile: path)
let target = ".modelContainer(container)"
let replacement = """
        .modelContainer(container)
        .task {
            #if DEBUG
            await PhotoAnalysisTests.runAll()
            #endif
        }
"""
content = content.replacingOccurrences(of: target, with: replacement)
try! content.write(toFile: path, atomically: true, encoding: .utf8)
