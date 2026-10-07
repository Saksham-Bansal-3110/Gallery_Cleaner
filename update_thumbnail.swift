import Foundation

let path = "Gallery Cleaner/Components/MediaThumbnail.swift"
var content = try! String(contentsOfFile: path)
content = content.replacingOccurrences(of: """
    var isSelectionMode: Bool
    var onTap: () -> Void
""", with: """
    var isSelectionMode: Bool
    var isRecommended: Bool = false
    var onTap: () -> Void
""")

let targetBadge = """
                if let duration = item.formattedDuration {
                    HStack {
                        Spacer()
                        Text(duration)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.black.opacity(0.78))
                            .clipShape(Capsule())
                    }
                }
"""

let newBadge = """
                HStack {
                    if isRecommended {
                        Text("Recommended")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.green.opacity(0.7))
                            .clipShape(Capsule())
                            .accessibilityLabel("Recommended to keep")
                    }
                    Spacer()
                    if let duration = item.formattedDuration {
                        Text(duration)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.black.opacity(0.78))
                            .clipShape(Capsule())
                    }
                }
"""
content = content.replacingOccurrences(of: targetBadge, with: newBadge)
try! content.write(toFile: path, atomically: true, encoding: .utf8)
