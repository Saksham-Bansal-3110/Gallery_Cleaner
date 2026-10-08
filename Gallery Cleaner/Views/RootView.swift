import SwiftUI

struct RootView: View {
    @State private var hasStarted: Bool = false
    
    var body: some View {
        Group {
            if hasStarted {
                HomeView()
                    .transition(.opacity)
            } else {
                OnboardingView(onStart: { hasStarted = true })
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: hasStarted)
    }
}
