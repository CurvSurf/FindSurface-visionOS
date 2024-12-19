//
//  Cylinder.swift
//
//
//  Created by CurvSurf-SGKim on 6/14/24.
//

import Foundation
import simd

import FindSurfaceFramework

/// An object that contains geometric information about cylindrical objects (e.g., pipes, pillars.)
public struct Cylinder: GeometryObject {
    
    /// The height (or length) of the cylinder.
    public var height: Float
    
    /// The radius of the cylinder.
    public var radius: Float
    
    private var _extrinsics: [simd_float4]
    
    /// The 4x4 matrix that contains the cylinder's orientation and position.
    public var extrinsics: simd_float4x4 {
        get { .init(from: _extrinsics) }
        set { _extrinsics = newValue.columnArray }
    }
    
    /// Initializes `Cylinder` with the given `height`, `radius` and extrinsic parameters (`extrinsics`.)
    public init(height: Float, radius: Float, extrinsics: simd_float4x4) {
        self.height = height
        self.radius = radius
        self._extrinsics = extrinsics.columnArray
    }
}

public extension Cylinder {
    
    /// The axis of the cylinder.
    var axis: simd_float3 {
        get { yAxis }
        set { yAxis = newValue }
    }
    
    /// The center position of the cylinder.
    var center: simd_float3 {
        get { position }
        set { position = newValue }
    }
    
    /// The top-center position of the cylinder.
    var top: simd_float3 { center + 0.5 * height * axis }
    
    /// The bottom-center position of the cylinder.
    var bottom: simd_float3 { center - 0.5 * height * axis }
}

internal extension Cylinder {
    
    /// Initializes a `Cylinder` from `FindCylinderResult`.
    init(from result: FindCylinderResult) {
        self.init(height: result.height, radius: result.radius,
                  extrinsics: .extrinsics(yAxis: result.axis, position: result.center))
    }
}

public extension Cylinder {
    
    /// Rotates the model space, so that the cylinder's `axis` is as close as possible to the `upwardDirection`.
    mutating func align(relativeTo upwardDirection: simd_float3 = .init(0, 1, 0)) {
        
        if dot(axis, upwardDirection) < 0 {
            // means upside down, flip vertically.
            xAxis *= -1
            axis *= -1
        }
    }
    
    /// Rotates the model space, so that the cylinder's `axis` is as close as possible to the `upwardDirection`.
    func aligned(relativeTo upwardDirection: simd_float3 = .init(0, 1, 0)) -> Cylinder {
        var this = self
        this.align(relativeTo: upwardDirection)
        return this
    }
}
