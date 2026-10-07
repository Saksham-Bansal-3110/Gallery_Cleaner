//
//  MediaGroup.swift
//  Gallery Cleaner
//

import Foundation

public struct DuplicateGroup: Identifiable {
    public let id: String
    public let title: String
    public let items: [MediaItem]
    
    public init(id: String, title: String, items: [MediaItem]) {
        self.id = id
        self.title = title
        self.items = items
    }
}

public enum CategoryDisplayStyle {
    case grid(items: [MediaItem])
    case grouped(groups: [DuplicateGroup])
}
