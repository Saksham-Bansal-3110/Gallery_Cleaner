import Foundation

public struct BKTree {
    private class Node {
        let id: String
        let hash: UInt64
        var children: [Int: Node] = [:]
        
        init(id: String, hash: UInt64) {
            self.id = id
            self.hash = hash
        }
    }
    
    private var root: Node?
    
    public init() {}
    
    public mutating func insert(id: String, hash: UInt64) {
        if let root = root {
            insert(node: root, id: id, hash: hash)
        } else {
            root = Node(id: id, hash: hash)
        }
    }
    
    private func insert(node: Node, id: String, hash: UInt64) {
        let dist = Int(node.hash.nonzeroBitCount(with: hash)) // Hamming distance
        if dist == 0 && node.id == id { return } // exact match already
        
        if let child = node.children[dist] {
            insert(node: child, id: id, hash: hash)
        } else {
            node.children[dist] = Node(id: id, hash: hash)
        }
    }
    
    public func search(hash: UInt64, maxDistance: Int) -> [String] {
        guard let root = root else { return [] }
        var results = [String]()
        search(node: root, hash: hash, maxDistance: maxDistance, results: &results)
        return results
    }
    
    private func search(node: Node, hash: UInt64, maxDistance: Int, results: inout [String]) {
        let dist = Int(node.hash.nonzeroBitCount(with: hash))
        if dist <= maxDistance {
            results.append(node.id)
        }
        
        for d in max(0, dist - maxDistance)...(dist + maxDistance) {
            if let child = node.children[d] {
                search(node: child, hash: hash, maxDistance: maxDistance, results: &results)
            }
        }
    }
}

fileprivate extension UInt64 {
    func nonzeroBitCount(with other: UInt64) -> Int {
        return (self ^ other).nonzeroBitCount
    }
}
