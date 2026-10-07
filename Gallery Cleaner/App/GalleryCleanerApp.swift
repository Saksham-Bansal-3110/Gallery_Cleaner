//
//  GalleryCleanerApp.swift
//  Gallery Cleaner
//

import SwiftUI

@main
struct GalleryCleanerApp: App {
    @StateObject private var galleryViewModel = GalleryViewModel(
        photoLibraryService: PhotoLibraryManager()
    )
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(galleryViewModel)
        }
    }
}
