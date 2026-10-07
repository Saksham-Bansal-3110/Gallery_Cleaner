//
//  MediaThumbnail.swift
//  Gallery Cleaner
//

import SwiftUI
import Photos

struct MediaThumbnail: View {
    let item: MediaItem
    var isSelected: Bool
    var isSelectionMode: Bool
    var onTap: () -> Void
    
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
                        .background(Color.white.opacity(0.3))
                        .clipShape(Capsule())
                    Spacer()
                }
                Spacer()
                if let duration = item.formattedDuration {
                    HStack {
                        Spacer()
                        Text(duration)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(4)
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
        .onTapGesture {
            onTap()
        }
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
        // Approximate size for a grid cell
        let targetSize = CGSize(width: 120, height: 120)
        imageRequestID = galleryViewModel.photoLibraryService.requestThumbnail(for: item, targetSize: targetSize) { image in
            if let image = image {
                self.thumbnailImage = image
            }
        }
    }
}
