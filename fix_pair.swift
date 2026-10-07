import Foundation
let path = "Gallery Cleaner/Services/Similarity/CandidateGenerator.swift"
var content = try! String(contentsOfFile: path)
content = content.replacingOccurrences(of: "public struct CandidatePair: Hashable {", with: "public struct CandidatePair: Hashable, Sendable {")
try! content.write(toFile: path, atomically: true, encoding: .utf8)
