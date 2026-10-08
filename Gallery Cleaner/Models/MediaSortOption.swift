import Foundation

public enum MediaSortOption: String, CaseIterable, Identifiable {
    case defaultOrder = "Default"
    case newest = "Newest First"
    case oldest = "Oldest First"
    case largest = "Largest First"
    case smallest = "Smallest First"
    
    public var id: String { self.rawValue }
}
