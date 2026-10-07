import Foundation
let path = "Gallery Cleaner/Services/Similarity/PhotoAnalysisService.swift"
var content = try! String(contentsOfFile: path)
content = content.replacingOccurrences(of: """
public struct PhotoAnalysisDiagnostics {
    public var totalRequested: Int = 0
    public var dHashSuccesses: Int = 0
    public var dHashFailures: Int = 0
    public var visionSuccesses: Int = 0
    public var visionFailures: Int = 0
    public var cacheHits: Int = 0
    public var cacheMisses: Int = 0
    public var totalAnalysisTime: TimeInterval = 0
    
    // Concurrency tracking
    public var peakConcurrentCount: Int = 0
    private var currentConcurrentCount: Int = 0
    
    mutating func incrementConcurrent() {
        currentConcurrentCount += 1
        peakConcurrentCount = max(peakConcurrentCount, currentConcurrentCount)
    }
    mutating func decrementConcurrent() {
        currentConcurrentCount = max(0, currentConcurrentCount - 1)
    }
}
""", with: "")
content = content.replacingOccurrences(of: "public var diagnostics = PhotoAnalysisDiagnostics()", with: """
    // Diagnostics
    public var totalRequested: Int = 0
    public var dHashSuccesses: Int = 0
    public var dHashFailures: Int = 0
    public var visionSuccesses: Int = 0
    public var visionFailures: Int = 0
    public var cacheHits: Int = 0
    public var cacheMisses: Int = 0
    public var totalAnalysisTime: TimeInterval = 0
    public var peakConcurrentCount: Int = 0
    private var currentConcurrentCount: Int = 0
""")
content = content.replacingOccurrences(of: "diagnostics.", with: "")
content = content.replacingOccurrences(of: """
    mutating func incrementConcurrent() {
""", with: "")
content = content.replacingOccurrences(of: """
    mutating func decrementConcurrent() {
""", with: "")
content = content.replacingOccurrences(of: "incrementConcurrent()", with: """
        currentConcurrentCount += 1
        peakConcurrentCount = max(peakConcurrentCount, currentConcurrentCount)
""")
content = content.replacingOccurrences(of: "decrementConcurrent()", with: """
        currentConcurrentCount = max(0, currentConcurrentCount - 1)
""")

try! content.write(toFile: path, atomically: true, encoding: .utf8)
