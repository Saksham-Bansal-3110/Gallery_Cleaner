import Foundation
import Vision

public struct SimilarityConfiguration: Sendable {
    public nonisolated static let shared = SimilarityConfiguration()
    
    // Versioning
    public let algorithmVersion: Int = 2
    
    // Thresholds
    public let strongSimilarityThreshold: Float = 2.5
    public let weakSimilarityThreshold: Float = 14.0
    
    // Perceptual Hash bounds
    public let dHashStrongThreshold: Int = 12 // Hamming distance
    public let dHashWeakThreshold: Int = 20
    
    // Temporal constraints
    public let closeTemporalProximity: TimeInterval = 60 * 5 // 5 minutes
    public let sameDayTemporalProximity: TimeInterval = 24 * 60 * 60 // 24 hours
    
    // Concurrency bounds
    public let maxVisionConcurrentTasks: Int = 8
    public let maxHashConcurrentTasks: Int = 16
    
    private init() {}
    
    public nonisolated var currentVisionRevision: Int {
        if #available(iOS 17.0, *) {
            return VNGenerateImageFeaturePrintRequestRevision2
        } else {
            return VNGenerateImageFeaturePrintRequestRevision1
        }
    }
}
