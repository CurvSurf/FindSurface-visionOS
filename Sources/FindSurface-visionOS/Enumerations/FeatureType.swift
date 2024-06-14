//
//  FeatureType.swift
//
//
//  Created by CurvSurf-SGKim on 6/17/24.
//

import Foundation

import FindSurfaceFramework

/// A type of geometric shape that can be asked to or found by FindSurface.
public enum FeatureType: CaseIterable {
    
    /// Allows FindSurface to detect the optimal parametric surface from the given pointcloud.
    case any
    
    /// Forces FindSurface to detect only a planar surface from the given pointcloud.
    case plane
    
    /// Forces FindSurface to detect only a spherical surface from the given pointcloud.
    case sphere
    
    /// Forces FindSurface to detect only a cylindrical surface from the given pointcloud.
    case cylinder
    
    /// Forces FindSurface to detect only a conical surface from the given pointcloud.
    case cone
    
    /// Forces FindSurface to detect only a toroidal surface from the given pointcloud.
    case torus
}

internal extension FeatureType {
    
    /// Initializes `FeatureType` from `RawFindSurface.FeatureType`.
    init(_ rawValue: RawFindSurface.FeatureType) {
        switch rawValue {
        case .any:      self = .any
        case .plane:    self = .plane
        case .sphere:   self = .sphere
        case .cylinder: self = .cylinder
        case .cone:     self = .cone
        case .torus:    self = .torus
        @unknown default: fatalError()
        }
    }
}

internal extension RawFindSurface.FeatureType {
    
    init(_ type: FeatureType) {
        switch type {
        case .any:      self = .any
        case .plane:    self = .plane
        case .sphere:   self = .sphere
        case .cylinder: self = .cylinder
        case .cone:     self = .cone
        case .torus:    self = .torus
        }
    }
}
