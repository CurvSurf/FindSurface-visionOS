//
//  GeometryObject.swift
//
//
//  Created by CurvSurf-SGKim on 6/14/24.
//

import Foundation
import simd

public protocol GeometryObject: Codable, Hashable {
    
    /// The 4x4 matrix that contains the object's orientation and position.
    var extrinsics: simd_float4x4 { get set }
}

public extension GeometryObject {
    
    /// The basis vector of X axis of the object's model space.
    var xAxis: simd_float3 {
        get { extrinsics.basisX }
        set { extrinsics.basisX = newValue }
    }
    
    /// The basis vector of Y axis of the object's model space.
    var yAxis: simd_float3 {
        get { extrinsics.basisY }
        set { extrinsics.basisY = newValue }
    }
    
    /// The basis vector of Z axis of the object's model space.
    var zAxis: simd_float3 {
        get { extrinsics.basisZ }
        set { extrinsics.basisZ = newValue }
    }
    
    /// The position of the object.
    var position: simd_float3 {
        get { extrinsics.position }
        set { extrinsics.position = newValue }
    }
    
    /// The transformation matrix that converts to the object's model space.
    var transform: simd_float4x4 {
        .transform(xAxis: xAxis, yAxis: yAxis, zAxis: zAxis, origin: position)
    }
}

internal extension simd_float4x4 {
    
    var columnArray: [simd_float4] { [columns.0, columns.1, columns.2, columns.3] }
    init(from columnArray: [simd_float4]) { self.init(columnArray[0], columnArray[1], columnArray[2], columnArray[3]) }
    
    var basisX: simd_float3 {
        get { simd_make_float3(columns.0) }
        set { columns.0 = simd_float4(newValue, columns.0.w) }
    }
    
    var basisY: simd_float3 {
        get { simd_make_float3(columns.1) }
        set { columns.1 = simd_float4(newValue, columns.1.w) }
    }
    
    var basisZ: simd_float3 {
        get { simd_make_float3(columns.2) }
        set { columns.2 = simd_float4(newValue, columns.2.w) }
    }
    
    var position: simd_float3 {
        get { simd_make_float3(columns.3) }
        set { columns.3 = simd_float4(newValue, columns.3.w) }
    }
    
    /// makes an extrinsic matrix that contains an object's orientation and location.
    static func extrinsics(xAxis: simd_float3,
                           yAxis: simd_float3,
                           zAxis: simd_float3,
                           position: simd_float3 = .zero) -> simd_float4x4 {
        return .init(.init(xAxis, 0),
                     .init(yAxis, 0),
                     .init(zAxis, 0),
                     .init(position, 1))
    }
    
    /// makes an extrinsic matrix that contains an object's location.
    static func extrinsics(position: simd_float3) -> simd_float4x4 {
        return .init(.init(1, 0, 0, 0),
                     .init(0, 1, 0, 0),
                     .init(0, 0, 1, 0),
                     .init(position, 1))
    }
    
    /// makes an extrinsic matrix that contains an object's orientation and location.
    /// - note: the Y axis and Z axis are arbitrarily determined by attempting cross products with the given `xAxis`.
    static func extrinsics(xAxis: simd_float3, position: simd_float3 = .zero) -> simd_float4x4 {
        let xAxis = normalize(xAxis)
        var yAxis = simd_float3(0, 1, 0)
        var zAxis = simd_float3(0, 0, 1)
        zAxis = if xAxis != yAxis {
            normalize(cross(xAxis, yAxis))
        } else {
            normalize(cross(xAxis, zAxis))
        }
        yAxis = normalize(cross(zAxis, xAxis))
        return .extrinsics(xAxis: xAxis, yAxis: yAxis, zAxis: zAxis, position: position)
    }
    
    /// makes an extrinsic matrix that contains an object's orientation and location.
    /// - note: the X axis and Z axis are arbitrarily determined by attempting cross products with the given `yAxis`.
    static func extrinsics(yAxis: simd_float3, position: simd_float3 = .zero) -> simd_float4x4 {
        var xAxis = simd_float3(1, 0, 0)
        let yAxis = normalize(yAxis)
        var zAxis = simd_float3(0, 0, 1)
        xAxis = if yAxis != zAxis {
            normalize(cross(yAxis, zAxis))
        } else {
            normalize(cross(yAxis, xAxis))
        }
        zAxis = normalize(cross(xAxis, yAxis))
        return .extrinsics(xAxis: xAxis, yAxis: yAxis, zAxis: zAxis, position: position)
    }
    
    /// makes an extrinsic matrix that contains an object's orientation and location.
    /// - note: the X axis and Y axis are arbitrarily determined by attempting cross products with the given `zAxis`.
    static func extrinsics(zAxis: simd_float3, position: simd_float3 = .zero) -> simd_float4x4 {
        var xAxis = simd_float3(1, 0, 0)
        var yAxis = simd_float3(0, 1, 0)
        let zAxis = normalize(zAxis)
        yAxis = if zAxis != xAxis {
            normalize(cross(zAxis, xAxis))
        } else {
            normalize(cross(zAxis, yAxis))
        }
        xAxis = normalize(cross(yAxis, zAxis))
        return .extrinsics(xAxis: xAxis, yAxis: yAxis, zAxis: zAxis, position: position)
    }
    
    /// makes a transformation matrix that converts coordinates to a model coordinate system defined by `xAxis`, `yAxis`, `zAxis`, and `origin`.
    static func transform(xAxis: simd_float3,
                          yAxis: simd_float3,
                          zAxis: simd_float3,
                          origin: simd_float3 = .zero) -> simd_float4x4 {
        return .init(rows: [.init(xAxis, -dot(origin, xAxis)),
                            .init(yAxis, -dot(origin, yAxis)),
                            .init(zAxis, -dot(origin, zAxis)),
                            .init(0, 0, 0, 1)])
    }
}

