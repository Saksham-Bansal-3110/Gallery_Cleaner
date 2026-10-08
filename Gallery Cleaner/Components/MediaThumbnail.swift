import SwiftUI
import Photos

struct MediaThumbnail: View {
    let item: MediaItem
    var isSelected: Bool
    var isSelectionMode: Bool
    var isRecommended: Bool = false
    var onTap: () -> Void // Keeping for API compatibility, but unused internally
    
    @EnvironmentObject var galleryViewModel: GalleryViewModel
    @State private var thumbnailImage: UIImage?
    @State private var imageRequestID: PHImageRequestID?
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Image Background
            if let image = thumbnailImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(white: 0.2))
                    .aspectRatio(1, contentMode: .fit)
            }
            
            // Badges
            VStack {
                HStack {
                    Text(item.formattedSize)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.black.opacity(0.78))
                        .clipShape(Capsule())
                    Spacer()
                }
                Spacer()
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
            }
            .padding(6)
            
            // Selection Indicator
            if isSelectionMode {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 20))
                            .foregroundColor(isSelected ? .blue : .white)
                            .background(
                                Circle()
                                    .fill(isSelected ? Color.white : Color.clear)
                                    .frame(width: 18, height: 18)
                            )
                            .padding(6)
                    }
                }
            }
        }
        .contentShape(Rectangle())
        .onAppear {
            loadImage()
        }
        .onDisappear {
            if let requestID = imageRequestID {
                galleryViewModel.photoLibraryService.cancelThumbnailRequest(requestID)
            }
        }
    }
    
    private func loadImage() {
        let targetSize = CGSize(width: 120, height: 120)
        imageRequestID = galleryViewModel.photoLibraryService.requestThumbnail(for: item, targetSize: targetSize) { image in
            if let image = image {
                self.thumbnailImage = image
            }
        }
    }
}
