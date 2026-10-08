import SwiftUI

struct OnboardingView: View {
    var onStart: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 32) {
                    // Hero Section
                    VStack(spacing: 16) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 64))
                            .foregroundStyle(.tint)
                            .padding(.top, 40)
                        
                        Text("Gallery Cleaner")
                            .font(.largeTitle.weight(.bold))
                            .foregroundStyle(.primary)
                        
                        VStack(spacing: 8) {
                            Text("Take back your storage.")
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(.primary)
                            
                            Text("Find and clean up the photos and videos taking up the most space.")
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                        }
                    }
                    
                    // Features
                    VStack(alignment: .leading, spacing: 24) {
                        Text("FEATURES")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .padding(.leading, 8)
                        
                        FeatureRow(
                            icon: "camera.viewfinder",
                            title: "Screenshots",
                            description: "Quickly find screenshots taking up space.",
                            iconColor: .red
                        )
                        FeatureRow(
                            icon: "square.on.square",
                            title: "Duplicate Photos & Videos",
                            description: "Find exact duplicates and review them before deleting.",
                            iconColor: .cyan
                        )
                        FeatureRow(
                            icon: "square.stack.3d.up",
                            title: "Similar Photos",
                            description: "Find visually similar shots and choose which ones to keep.",
                            iconColor: .purple
                        )
                        FeatureRow(
                            icon: "video",
                            title: "Large Videos",
                            description: "Quickly identify videos consuming the most storage.",
                            iconColor: .blue
                        )
                        FeatureRow(
                            icon: "chart.bar",
                            title: "Storage Overview",
                            description: "See what is taking up space in your photo library.",
                            iconColor: .green
                        )
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 40)
            }
            
            // Bottom Button
            VStack {
                Button(action: {
                    withAnimation {
                        onStart()
                    }
                }) {
                    Text("Get Started")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.accentColor)
                        .cornerRadius(16)
                }
                .accessibilityLabel("Get Started with Gallery Cleaner")
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
            }
            .background(Color(.systemBackground).ignoresSafeArea(edges: .bottom))
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .scrollIndicators(.hidden)
    }
}

struct FeatureRow: View {
    var icon: String
    var title: String
    var description: String
    var iconColor: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundStyle(iconColor)
                .frame(width: 32, alignment: .center)
                .accessibilityHidden(true)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
    }
}
