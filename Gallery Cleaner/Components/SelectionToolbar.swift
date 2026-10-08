//
//  SelectionToolbar.swift
//  Gallery Cleaner
//

import SwiftUI

struct SelectionToolbar: View {
    var onSelectAll: () -> Void
    var onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Button(action: onSelectAll) {
                Text("Select All")
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(.tertiarySystemFill))
                    .clipShape(Capsule())
            }
            
            Button(action: onDelete) {
                Text("Delete")
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(.tertiarySystemFill))
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 24)
        .background(Color(.systemBackground))
    }
}
