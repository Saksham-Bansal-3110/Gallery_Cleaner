//
//  GalleryCleanerApp.swift
//  Gallery Cleaner
//

import SwiftUI
import SwiftData

@main
struct GalleryCleanerApp: App {
    @StateObject private var galleryViewModel = GalleryViewModel(
        photoLibraryService: PhotoLibraryManager()
    )
    
    let container: ModelContainer
    
    init() {
        do {
            let tempContainer = try ModelContainer(for: AssetAnalysisData.self)
            self.container = tempContainer

        } catch {
            fatalError("Failed to initialize SwiftData container.")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(galleryViewModel)
                .task {
                    #if DEBUG
                    await PhotoAnalysisTests.runAll(container: container)
                    await SimilarityTests.runAll()
                    PhotoRankingTests.runAll()
                    #endif
                }
        }
        .modelContainer(container)
    }
}
