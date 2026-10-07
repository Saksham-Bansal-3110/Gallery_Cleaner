import Foundation
let path1 = "Gallery Cleaner/Services/Similarity/VisionFeatureService.swift"
var content1 = try! String(contentsOfFile: path1)
content1 = content1.replacingOccurrences(of: """
                    let data = result.data
""", with: """
                    let data = try NSKeyedArchiver.archivedData(withRootObject: result, requiringSecureCoding: true)
""")
try! content1.write(toFile: path1, atomically: true, encoding: .utf8)

let path2 = "Gallery Cleaner/Services/Similarity/SimilarityScorer.swift"
var content2 = try! String(contentsOfFile: path2)

content2 = content2.replacingOccurrences(of: """
                let type1 = VNElementType(rawValue: UInt(a1.visionElementType)) ?? .float
                let type2 = VNElementType(rawValue: UInt(a2.visionElementType)) ?? .float
                
                let obs1 = try VNFeaturePrintObservation(data: a1.visionFeatureData, elementType: type1, elementCount: a1.visionElementCount)
                let obs2 = try VNFeaturePrintObservation(data: a2.visionFeatureData, elementType: type2, elementCount: a2.visionElementCount)
""", with: """
                guard let obs1 = try NSKeyedUnarchiver.unarchivedObject(ofClass: VNFeaturePrintObservation.self, from: a1.visionFeatureData) else { continue }
                guard let obs2 = try NSKeyedUnarchiver.unarchivedObject(ofClass: VNFeaturePrintObservation.self, from: a2.visionFeatureData) else { continue }
""")

// Also fix the diagnostics struct mutation bug:
content2 = content2.replacingOccurrences(of: """
public struct SimilarityScorerDiagnostics {
""", with: """
public class SimilarityScorerDiagnostics {
    public init() {}
""")
try! content2.write(toFile: path2, atomically: true, encoding: .utf8)
