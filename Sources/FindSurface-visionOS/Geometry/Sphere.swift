//
//  Sphere.swift
//
//
//  Created by CurvSurf-SGKim on 6/14/24.
//

import Foundation
import simd

import FindSurfaceFramework

/// An object that contains geometric information about spherical objects (e.g., basketball balls, hemispheres.)
public struct Sphere: GeometryObject {
    
    /// The radius of the sphere.
    public var radius: Float
    
    private var _extrinsics: [simd_float4]
    
    /// The 4x4 matrix that contains the sphere's orientation and position.
    public var extrinsics: simd_float4x4 {
        get { .init(from: _extrinsics) }
        set { _extrinsics = newValue.columnArray }
    }
    
    /// Initializes `Sphere` with `radius` and extrinsic parameters (`extrinsics`.)
    public init(radius: Float, extrinsics: simd_float4x4) {
        self.radius = radius
        self._extrinsics = extrinsics.columnArray
    }
}

public extension Sphere {
    
    /// The center position of the sphere.
    var center: simd_float3 {
        get { position }
        set { position = newValue }
    }
}

internal extension Sphere {
    
    /// Initializes a `Sphere` from `FindSphereResult`.
    init(from result: FindSphereResult) {
        self.init(radius: result.radius, extrinsics: .extrinsics(position: result.center))
    }
}
