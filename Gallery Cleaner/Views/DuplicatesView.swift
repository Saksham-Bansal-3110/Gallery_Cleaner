//
//  DuplicatesView.swift
//  Gallery Cleaner
//

import SwiftUI

struct DuplicatesView: View {
    @Environment(\.dismiss) var dismiss
    @State private var isSelectionMode = false
    @State private var selectedGroups: Set<Int> = []
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Duplicates")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.white)
                        Text("142 Items • 102 MB")
                            .font(.system(size: 14))
                            .foregroundColor(Color(white: 0.6))
                    }
                    Spacer()
                    
                    Button(action: {
                        isSelectionMode.toggle()
                    }) {
                        Text(isSelectionMode ? "Cancel" : "Select")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color(white: 0.4))
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 16)
                
                // List
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(0..<10, id: \.self) { index in
                            DuplicateGroupView(
                                title: "IMG-2349265798-WA00\(index).jpg",
                                isSelected: selectedGroups.contains(index),
                                onToggleSelection: {
                                    if selectedGroups.contains(index) {
                                        selectedGroups.remove(index)
                                    } else {
                                        selectedGroups.insert(index)
                                    }
                                },
                                itemsCount: 2
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100) // Space for toolbar
                }
            }
            
            if isSelectionMode || !selectedGroups.isEmpty {
                VStack {
                    Spacer()
                    SelectionToolbar(onSelectAll: {
                        if selectedGroups.count == 10 {
                            selectedGroups.removeAll()
                        } else {
                            selectedGroups = Set(0..<10)
                        }
                    }, onDelete: {
                        // Delete action mock
                    })
                }
            }
        }
        .navigationBarHidden(true)
    }
}
