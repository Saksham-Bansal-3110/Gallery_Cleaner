import Combine
import SwiftUI
import Photos
import AVKit

class MediaDetailViewModel: ObservableObject {
    let item: MediaItem
    
    @Published var image: UIImage?
    @Published var player: AVPlayer?
    @Published var isLoading: Bool = false
    @Published var loadError: Bool = false
    
    private var imageRequestID: PHImageRequestID?
    
    init(item: MediaItem) {
        self.item = item
    }
    
    @MainActor
    func loadMedia(targetSize: CGSize) {
        guard image == nil && player == nil else { return }
        
        isLoading = true
        loadError = false
        
        if item.mediaType == .video {
            let options = PHVideoRequestOptions()
            options.isNetworkAccessAllowed = true
            options.deliveryMode = .fastFormat
            
            PHImageManager.default().requestPlayerItem(forVideo: item.asset, options: options) { [weak self] playerItem, info in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.isLoading = false
                    if let playerItem = playerItem {
                        self.player = AVPlayer(playerItem: playerItem)
                    } else {
                        self.loadError = true
                    }
                }
            }
        } else {
            let options = PHImageRequestOptions()
            options.isNetworkAccessAllowed = true
            options.deliveryMode = .opportunistic
            options.resizeMode = .fast
            
            imageRequestID = PHImageManager.default().requestImage(for: item.asset, targetSize: targetSize, contentMode: .aspectFit, options: options) { [weak self] img, info in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    
                    let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool) ?? false
                    
                    if let img = img {
                        self.image = img
                        if !isDegraded {
                            self.isLoading = false
                        }
                    } else if !isDegraded {
                        self.isLoading = false
                        self.loadError = true
                    }
                }
            }
        }
    }
    
    func cancelLoading() {
        if let id = imageRequestID {
            PHImageManager.default().cancelImageRequest(id)
            imageRequestID = nil
        }
        player?.pause()
        player = nil
    }
}

struct MediaInfoSheet: View {
    let item: MediaItem
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Media Information").font(.headline).padding(.bottom, 4)) {
                    HStack {
                        Text("Type").foregroundStyle(.secondary)
                        Spacer()
                        if item.mediaType == .video {
                            Text("Video")
                        } else if item.asset.mediaSubtypes.contains(.photoLive) {
                            Text("Live Photo")
                        } else {
                            Text("Photo")
                        }
                    }
                    
                    if let date = item.creationDate {
                        HStack {
                            Text("Date Taken").foregroundStyle(.secondary)
                            Spacer()
                            Text(date, format: .dateTime.month().day().year())
                        }
                    }
                    
                    if item.mediaType == .video, let duration = item.formattedDuration {
                        HStack {
                            Text("Duration").foregroundStyle(.secondary)
                            Spacer()
                            Text(duration)
                        }
                    }
                    
                    HStack {
                        Text("Dimensions").foregroundStyle(.secondary)
                        Spacer()
                        Text("\(item.pixelWidth) × \(item.pixelHeight)")
                    }
                    
                    HStack {
                        Text("File Size").foregroundStyle(.secondary)
                        Spacer()
                        Text(item.formattedSize)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

@MainActor struct MediaDetailContentView: View {
    let item: MediaItem
    let activeItemId: String
    @EnvironmentObject var galleryViewModel: GalleryViewModel
    
    @StateObject private var viewModel: MediaDetailViewModel
    
    // Zoom state
    @State private var scale: CGFloat = 1.0
    @State private var panOffset: CGSize = .zero
    
    @MainActor
    init(item: MediaItem, activeItemId: String) {
        self.item = item
        self.activeItemId = activeItemId
        _viewModel = StateObject(wrappedValue: MediaDetailViewModel(item: item))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                
                if item.mediaType == .video {
                    if let player = viewModel.player {
                        VideoPlayer(player: player)
                            .ignoresSafeArea(edges: .bottom)
                    } else if viewModel.isLoading {
                        ProgressView().progressViewStyle(.circular).tint(.primary)
                    } else if viewModel.loadError {
                        Text("Unable to Load Video")
                            .foregroundStyle(.secondary)
                    }
                } else {
                    if let image = viewModel.image {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
                            .scaleEffect(scale)
                            .offset(panOffset)
                            .gesture(
                                MagnifyGesture()
                                    .onChanged { value in
                                        scale = max(1.0, value.magnification)
                                    }
                                    .onEnded { _ in
                                        if scale <= 1.0 {
                                            withAnimation {
                                                scale = 1.0
                                                panOffset = .zero
                                            }
                                        }
                                    }
                            )
                            .simultaneousGesture(
                                DragGesture(minimumDistance: scale > 1.0 ? 0 : 10000)
                                    .onChanged { value in
                                        if scale > 1.0 {
                                            panOffset = value.translation
                                        }
                                    }
                                    .onEnded { _ in
                                        if scale <= 1.0 {
                                            withAnimation { panOffset = .zero }
                                        }
                                    }
                            )
                    } else if viewModel.isLoading {
                        ProgressView().progressViewStyle(.circular).tint(.primary)
                    } else if viewModel.loadError {
                        VStack {
                            Image(systemName: "exclamationmark.triangle").font(.system(size: 40)).foregroundStyle(.secondary)
                            Text("Failed to load image").foregroundStyle(.secondary).padding(.top, 8)
                        }
                    }
                }
            }
            .task(id: item.id) {
                let screenScale = UITraitCollection.current.displayScale
                let targetSize = CGSize(width: geometry.size.width * screenScale, height: geometry.size.height * screenScale)
                viewModel.loadMedia(targetSize: targetSize)
            }
            .onChange(of: activeItemId) { _, newId in
                if newId != item.id {
                    viewModel.player?.pause()
                } else {
                    let screenScale = UITraitCollection.current.displayScale
                    let targetSize = CGSize(width: geometry.size.width * screenScale, height: geometry.size.height * screenScale)
                    viewModel.loadMedia(targetSize: targetSize)
                }
            }
        }
        .onDisappear {
            viewModel.cancelLoading()
        }
    }
}

@MainActor struct MediaDetailView: View {
    let initialItem: MediaItem
    let allItems: [MediaItem]
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var galleryViewModel: GalleryViewModel
    
    @State private var currentItemId: String
    @State private var showingInfo = false
    @State private var showDeleteConfirmation = false
    
    init(initialItem: MediaItem, allItems: [MediaItem]) {
        self.initialItem = initialItem
        self.allItems = allItems
        self._currentItemId = State(initialValue: initialItem.id)
    }
    
    var currentItem: MediaItem? {
        allItems.first { $0.id == currentItemId }
    }
    
    var body: some View {
        TabView(selection: $currentItemId) {
            ForEach(allItems) { item in
                MediaDetailContentView(item: item, activeItemId: currentItemId)
                    .tag(item.id)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem() {
                Button(action: { showingInfo = true }) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.primary)
                }
                .accessibilityLabel(currentItem?.mediaType == .video ? "Video information" : "Photo information")
            }
            
            ToolbarSpacer(.fixed)
            
            ToolbarItem() {
                Button(action: { showDeleteConfirmation = true }) {
                    Image(systemName: "trash")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.primary)
                }
                .accessibilityLabel(currentItem?.mediaType == .video ? "Delete video" : "Delete photo")
            }
        }
        .sheet(isPresented: $showingInfo) {
            if let item = currentItem {
                MediaInfoSheet(item: item)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
        .confirmationDialog("Delete Media?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) { deleteItem() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will move the item to Recently Deleted.")
        }
    }
    
    private func deleteItem() {
        guard let item = currentItem else { return }
        Task {
            do {
                try await galleryViewModel.deleteItems(withIDs: [item.id])
                dismiss() // Return to category since array bounds might shift
            } catch {
                print("Failed to delete item: \(error)")
            }
        }
    }
}

