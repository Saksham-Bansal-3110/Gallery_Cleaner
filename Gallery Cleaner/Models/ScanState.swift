//
//  ScanState.swift
//  Gallery Cleaner
//

import Foundation

public enum ScanState: Equatable {
    case idle
    case requestingPermission
    case scanning(progress: Double)
    case completed
    case permissionDenied
    case failed(String)
}
