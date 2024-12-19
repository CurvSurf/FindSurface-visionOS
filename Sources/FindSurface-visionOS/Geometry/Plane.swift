//
//  Plane.swift
//
//
//  Created by CurvSurf-SGKim on 6/14/24.
//

import Foundation
import simd

import FindSurfaceFramework

/// An object that contains geometric information about orthogonal-bounded planar surfaces (e.i., rectangular surfaces.)
public struct Plane: GeometryObject {
    
    /// The width of the plane.
    public var width: Float
    
    /// The height of the plane.
    public var height: Float
    
    private var _extrinsics: [simd_float4]
    
    /// The 4x4 matrix that contains the plane's orientation and position.
    public var extrinsics: simd_float4x4 {
        get { .init(from: _extrinsics) }
        set { _extrinsics = newValue.columnArray }
    }
    
    /// Initializes `Plane` with the given `width`, `height`, and extrinsic parameters (`extrinsics`.)
    public init(width: Float, height: Float, extrinsics: simd_float4x4) {
        self.width = width
        self.height = height
        self._extrinsics = extrinsics.columnArray
    }
}

public extension Plane {
    
    /// The normal vector of the plane.
    var normal: simd_float3 {
        get { zAxis }
        set { zAxis = newValue }
    }
    
    /// The center position of the plane.
    var center: simd_float3 {
        get { position }
        set { position = newValue }
    }
    
    /// The right edge's midpoint of the plane.
    var right: simd_float3 { center + 0.5 * width * xAxis }
    
    /// The left edge's midpoint of the plane.
    var left: simd_float3 { center - 0.5 * width * xAxis }
    
    /// The top edge's midpoint of the plane.
    var top: simd_float3 { center + 0.5 * height * yAxis }
    
    /// The bottom edge's midpoint of the plane.
    var bottom: simd_float3 { center - 0.5 * height * yAxis }
    
    /// The bottom-left corner of the plane.
    var bottomLeft: simd_float3 { center - 0.5 * (width * xAxis + height * yAxis) }
    
    /// The top-left corner of the plane.
    var topLeft: simd_float3 { center - 0.5 * (width * xAxis - height * yAxis) }
    
    /// The top-right corner of the plane.
    var topRight: simd_float3 { center + 0.5 * (width * xAxis + height * yAxis) }
    
    /// The bottom-right corner of the plane.
    var bottomRight: simd_float3 { center + 0.5 * (width * xAxis - height * yAxis) }
}

internal extension Plane {
    
    /// Initializes `Plane` from `FindPlaneResult`.
    init(from result: FindPlaneResult) {
        
        let bottomLeft = result.lowerLeft
        let bottomRight = result.lowerRight
        let topLeft = result.upperLeft
        let topRight = result.upperRight
        
        let right = (bottomRight + topRight) * 0.5
        let left = (bottomLeft + topLeft) * 0.5
        let top = (topLeft + topRight) * 0.5
        let bottom = (bottomLeft + bottomRight) * 0.5
        
        let horizontal = right - left
        let vertical = top - bottom
        
        let width = length(horizontal)
        let height = length(vertical)
        
        let xAxis = normalize(horizontal)
        let yAxis = normalize(vertical)
        let zAxis = normalize(cross(xAxis, yAxis))
        
        let position = (bottomLeft + bottomRight + topRight + topLeft) * 0.25
        
        let extrinsics = simd_float4x4.extrinsics(xAxis: xAxis,
                                                  yAxis: yAxis,
                                                  zAxis: zAxis, 
                                                  position: position)
        
        self.init(width: width, height: height, extrinsics: extrinsics)
    }
}

public extension Plane {
    
    /// Rotates its model space, so that the plane's `normal` points to the camera and `yAxis` is as close as possible to the `upwardDirection`.
    mutating func align(withCamera cameraPosition: simd_float3, upwardDirection: simd_float3 = .init(0, 1, 0)) {
        
        if dot(yAxis, upwardDirection) < 0 {
            // means upside down, flip vertically.
            yAxis *= -1
            zAxis *= -1
        }
        
        let directionFromPlaneToCamera = normalize(cameraPosition - position)
        if dot(normal, directionFromPlaneToCamera) < 0 {
            // means having its back to the camera, flip horizontally.
            xAxis *= -1
            zAxis *= -1
        }
        
        let yDotUp = dot(yAxis, upwardDirection)
        if yDotUp < dot(xAxis, upwardDirection) {
            // means lying down to its right, rotate clockwise.
            let oldXAxis = xAxis
            xAxis = -yAxis
            yAxis = oldXAxis
            swap(&width, &height)
        }
        if yDotUp < dot(-xAxis, upwardDirection) {
            // means lying down to its left, rotate counter clockwise.
            let oldXAxis = xAxis
            xAxis = yAxis
            yAxis = -oldXAxis
            swap(&width, &height)
        }
    }
    
    /// Rotates the model space, so that the plane's `normal` points to the camera and `yAxis` is as close as possible to the `upwardDirection`.
    func aligned(withCamera cameraPosition: simd_float3, upwardDirection: simd_float3 = .init(0, 1, 0)) -> Plane {
        var this = self
        this.align(withCamera: cameraPosition, upwardDirection: upwardDirection)
        return this
    }
}
