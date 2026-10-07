import Foundation
let path = "Gallery Cleaner/Services/Similarity/PhotoAnalysisTests.swift"
var content = try! String(contentsOfFile: path)
content = content.replacingOccurrences(of: "import UIKit", with: "import UIKit\nimport SwiftData")
try! content.write(toFile: path, atomically: true, encoding: .utf8)
