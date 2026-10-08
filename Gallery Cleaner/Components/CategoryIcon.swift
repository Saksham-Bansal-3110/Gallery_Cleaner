import SwiftUI

struct CategoryIcon: View {
    var systemImage: String
    var color: Color
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(color)
                .frame(width: 48, height: 48)
            
            Image(systemName: systemImage)
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(.white)
        }
        .accessibilityHidden(true)
    }
}
