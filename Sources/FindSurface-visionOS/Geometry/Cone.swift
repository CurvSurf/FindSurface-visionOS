//
//  Cone.swift
//
//
//  Created by CurvSurf-SGKim on 6/17/24.
//

import Foundation
import simd

import FindSurfaceFramework

/// An object that contains geometric information about conical objects (e.g., cups, traffic cones.)
/// - Note: Technically, this object represents conical frustums.
public struct Cone: GeometryObject {
    
    /// The height (or length) between the top center and the bottom center of the conical frustum.
    public var height: Float
    
    /// The radius of the top section of the conical frustum.
    public var topRadius: Float
    
    /// The radius of the bottom section of the conical frustum.
    public var bottomRadius: Float
    
    private var _extrinsics: [simd_float4]
    
    /// The 4x4 matrix that contains the conical frustum's orientation and position.
    public var extrinsics: simd_float4x4 {
        get { .init(from: _extrinsics) }
        set { _extrinsics = newValue.columnArray }
    }
    
    /// Initializes `Cone` with the given `height`, `topRadius`, `bottomRadius` and extrinsic parameters (`extrinsics`.)
    public init(height: Float, topRadius: Float, bottomRadius: Float, extrinsics: simd_float4x4) {
        self.height = height
        self.topRadius = topRadius
        self.bottomRadius = bottomRadius
        self._extrinsics = extrinsics.columnArray
    }
}

public extension Cone {
    
    /// The axis of the conical frustum.
    var axis: simd_float3 {
        get { yAxis }
        set { yAxis = newValue }
    }
    
    /// The center position of the conical frustum.
    var center: simd_float3 {
        get { position }
        set { position = newValue }
    }
    
    /// The top-center position of the conical frustum.
    var top: simd_float3 { center + 0.5 * height * axis }
    
    /// The bottom-center position of the conical frustum.
    var bottom: simd_float3 { center - 0.5 * height * axis }
    
    /// The vertex position of the conical frustum.
    var vertex: simd_float3 { top + ((topRadius * height) / abs(bottomRadius - topRadius)) * axis }
}

internal extension Cone {
    
    /// Initializes a `Cone` from `FindConeResult`.
    init(from result: FindConeResult) {
        let axis = result.bottomRadius > result.topRadius ? result.axis : -result.axis
        let topRadius = min(result.bottomRadius, result.topRadius)
        let bottomRadius = max(result.bottomRadius, result.topRadius)
        let extrinsics = simd_float4x4.extrinsics(yAxis: axis, position: result.center)
        self.init(height: result.height, topRadius: topRadius, bottomRadius: bottomRadius, extrinsics: extrinsics)
    }
}
