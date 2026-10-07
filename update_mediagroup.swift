import Foundation

let path = "Gallery Cleaner/Models/MediaGroup.swift"
var content = try! String(contentsOfFile: path)
content = content.replacingOccurrences(of: """
    public let items: [MediaItem]
    
    public init(id: String, title: String, items: [MediaItem]) {
        self.id = id
        self.title = title
        self.items = items
    }
""", with: """
    public let items: [MediaItem]
    public var recommendedItem: MediaItem?
    public var rankedItems: [MediaItem]?
    
    public init(id: String, title: String, items: [MediaItem], recommendedItem: MediaItem? = nil, rankedItems: [MediaItem]? = nil) {
        self.id = id
        self.title = title
        self.items = items
        self.recommendedItem = recommendedItem
        self.rankedItems = rankedItems
    }
""")
try! content.write(toFile: path, atomically: true, encoding: .utf8)
