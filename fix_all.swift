import Foundation

let genPath = "Gallery Cleaner/Services/Similarity/CandidateGenerator.swift"
var gen = try! String(contentsOfFile: genPath)
gen = gen.replacingOccurrences(of: """
} else {
            self.firstID = id2
            self.secondID = id1
        }
    }
}

public struct CandidateGeneratorDiagnostics
""", with: """

public struct CandidateGeneratorDiagnostics""")
try! gen.write(toFile: genPath, atomically: true, encoding: .utf8)


let scoPath = "Gallery Cleaner/Services/Similarity/SimilarityScorer.swift"
var sco = try! String(contentsOfFile: scoPath)
sco = sco.replacingOccurrences(of: """
}
    
    public init() {}
    
    func record(distance: Float) {
""", with: """
    
    public init() {}
    
    func record(distance: Float) {""")
sco = sco.replacingOccurrences(of: """
        guard !allDistances.isEmpty else { return 0 }
        let sorted = allDistances.sorted()
        let index = Int(Float(sorted.count - 1) * p)
        return sorted[index]
    }
}
}

public actor SimilarityScorer {
""", with: """
        guard !allDistances.isEmpty else { return 0 }
        let sorted = allDistances.sorted()
        let index = Int(Float(sorted.count - 1) * p)
        return sorted[index]
    }
}

public actor SimilarityScorer {""")
try! sco.write(toFile: scoPath, atomically: true, encoding: .utf8)


let testPath = "Gallery Cleaner/Services/Similarity/SimilarityTests.swift"
var test = try! String(contentsOfFile: testPath)
test = test.replacingOccurrences(of: """
        print("Clusterer Case 3 (Missing Edge Rejection) passed.")
    }

    private static func testClustererCaseSplit() {
    private static func testClustererCaseSplit() {
""", with: """
        print("Clusterer Case 3 (Missing Edge Rejection) passed.")
    }

    private static func testClustererCaseSplit() {""")
test = test.replacingOccurrences(of: """
    private static func testClustererMissingEdgeABC() {
        let clusterer = SimilarityClusterer()
""", with: """
    private static func testClustererMissingEdgeABC() {
        let clusterer = SimilarityClusterer()
""")
try! test.write(toFile: testPath, atomically: true, encoding: .utf8)
