import SwiftUI

struct MediaSortSheet: View {
    @Binding var sortOption: MediaSortOption
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(MediaSortOption.allCases) { option in
                        Button(action: {
                            sortOption = option
                            dismiss()
                        }) {
                            HStack {
                                Text(option.rawValue)
                                    .foregroundStyle(.primary)
                                Spacer()
                                if sortOption == option {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Sort & Filter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    if sortOption != .defaultOrder {
                        Button("Reset") {
                            sortOption = .defaultOrder
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}
