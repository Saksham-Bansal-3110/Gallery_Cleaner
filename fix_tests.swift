import Foundation
let path = "Gallery Cleaner/Services/Similarity/PhotoAnalysisTests.swift"
var content = try! String(contentsOfFile: path)
content = content.replacingOccurrences(of: """
    public static func runAll() async {
""", with: """
    public static func runAll(container: SwiftData.ModelContainer) async {
""")
content = content.replacingOccurrences(of: """
        await testConcurrency()
""", with: """
        await testConcurrency(container: container)
""")
content = content.replacingOccurrences(of: """
    private static func testConcurrency() async {
        // We can instantiate PhotoAnalysisService and run it with empty array
        let service = PhotoAnalysisService()
""", with: """
    private static func testConcurrency(container: SwiftData.ModelContainer) async {
        let cache = PhotoAnalysisCache(modelContainer: container)
        let service = PhotoAnalysisService(cache: cache)
""")
try! content.write(toFile: path, atomically: true, encoding: .utf8)
