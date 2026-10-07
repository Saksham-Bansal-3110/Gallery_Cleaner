import Foundation

let path = "Gallery Cleaner/Components/CategoryCard.swift"
var content = try! String(contentsOfFile: path)
content = content.replacingOccurrences(of: "Button(action: action) {", with: "")
content = content.replacingOccurrences(of: """
            }
            
            if items.isEmpty {
""", with: """
            
            if items.isEmpty {
""")
try! content.write(toFile: path, atomically: true, encoding: .utf8)
