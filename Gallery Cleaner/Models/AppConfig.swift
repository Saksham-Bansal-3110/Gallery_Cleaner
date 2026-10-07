//
//  AppConfig.swift
//  Gallery Cleaner
//

import Foundation

public struct AppConfig {
    /// The threshold for considering a video "large" in bytes.
    /// Default is 50 MB.
    public static let largeVideoThreshold: Int64 = 50 * 1024 * 1024
}
