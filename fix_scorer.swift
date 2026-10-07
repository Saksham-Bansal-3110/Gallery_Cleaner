import Foundation
let path = "Gallery Cleaner/Services/Similarity/SimilarityScorer.swift"
var content = try! String(contentsOfFile: path)
content = content.replacingOccurrences(of: "public struct SimilarityScore {", with: "public struct SimilarityScore: Sendable {")
content = content.replacingOccurrences(of: "mutating func record", with: "func record")
try! content.write(toFile: path, atomically: true, encoding: .utf8)
