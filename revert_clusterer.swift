import Foundation
let path = "Gallery Cleaner/Services/Similarity/SimilarityClusterer.swift"
var content = try! String(contentsOfFile: path)
content = content.replacingOccurrences(of: "public actor SimilarityClustererDiagnostics", with: "public class SimilarityClustererDiagnostics")
try! content.write(toFile: path, atomically: true, encoding: .utf8)
