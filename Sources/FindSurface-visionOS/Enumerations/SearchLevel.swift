//
//  SearchLevel.swift
//  
//
//  Created by CurvSurf-SGKim on 6/17/24.
//

import Foundation

import FindSurfaceFramework

/// A tendency level for FindSurface related to its region growing strategy.
public enum SearchLevel: Int, CaseIterable {
    
    case off = 0
    case lv1 = 1
    case lv2 = 2
    case lv3 = 3
    case lv4 = 4
    case lv5 = 5
    case lv6 = 6
    case lv7 = 7
    case lv8 = 8
    case lv9 = 9
    case lv10 = 10
}

internal extension SearchLevel {
    
    /// Initializes `SearchLevel` from `RawFindSurface.SearchLevel`.
    init(_ rawValue: RawFindSurface.SearchLevel) {
        switch rawValue {
        case .off:              self = .off
        case .lv1, .moderate:   self = .lv1
        case .lv2:              self = .lv2
        case .lv3:              self = .lv3
        case .lv4:              self = .lv4
        case .lv5, .default:    self = .lv5
        case .lv6:              self = .lv6
        case .lv7:              self = .lv7
        case .lv8:              self = .lv8
        case .lv9:              self = .lv9
        case .lv10, .radical:   self = .lv10
        @unknown default:       fatalError()
        }
    }
}

internal extension RawFindSurface.SearchLevel {
    
    init(_ level: SearchLevel) {
        switch level {
        case .off:  self = .off
        case .lv1:  self = .lv1
        case .lv2:  self = .lv2
        case .lv3:  self = .lv3
        case .lv4:  self = .lv4
        case .lv5:  self = .lv5
        case .lv6:  self = .lv6
        case .lv7:  self = .lv7
        case .lv8:  self = .lv8
        case .lv9:  self = .lv9
        case .lv10: self = .lv10
        }
    }
}
