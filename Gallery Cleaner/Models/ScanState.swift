//
//  ScanState.swift
//  Gallery Cleaner
//

import Foundation

public enum ScanState: Equatable {
    case idle
    case requestingPermission
    case scanning
    case completed
    case permissionDenied
    case failed(String)
}
