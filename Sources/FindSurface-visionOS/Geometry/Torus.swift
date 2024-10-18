//
//  Torus.swift
//
//
//  Created by CurvSurf-SGKim on 6/17/24.
//

import Foundation
import simd

import FindSurfaceFramework

/// An object that contains geometric information about torus objects (e.g., donuts, tires.)
public struct Torus: GeometryObject {
    
    /// The major radius of the torus.
    public var meanRadius: Float
    
    /// The minor radius of the torus.
    public var tubeRadius: Float
    
    private var _extrinsics: [simd_float4]
    
    /// The 4x4 matrix that contains the torus's orientation and position.
    public var extrinsics: simd_float4x4 {
        get { .init(from: _extrinsics) }
        set { _extrinsics = newValue.columnArray }
    }
    
    /// Initializes `Torus` with the given `meanRadius`, `tubeRadius` and extrinsic parameters (`extrinsics`.)
    public init(meanRadius: Float, tubeRadius: Float, extrinsics: simd_float4x4) {
        self.meanRadius = meanRadius
        self.tubeRadius = tubeRadius
//        self.extrinsics = extrinsics
        self._extrinsics = extrinsics.columnArray
    }
}

//extension Torus: Hashable, Codable {
//    
//    enum CodingKeys: MatrixCodingKey {
//        case meanRadius, tubeRadius
//        case column0, column1, column2, column3
//    }
//    
//    public init(from decoder: any Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        let meanRadius = try container.decode(Float.self, forKey: .meanRadius)
//        let tubeRadius = try container.decode(Float.self, forKey: .tubeRadius)
//        let extrinsics = try decodeMatrix(from: container)
//        self.init(meanRadius: meanRadius, tubeRadius: tubeRadius,
//                  extrinsics: extrinsics)
//    }
//    
//    public func encode(to encoder: any Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(meanRadius, forKey: .meanRadius)
//        try container.encode(tubeRadius, forKey: .tubeRadius)
//        try encodeMatrix(extrinsics, to: &container)
//    }
//    
//    public func hash(into hasher: inout Hasher) {
//        hasher.combine(meanRadius)
//        hasher.combine(tubeRadius)
//        combineMatrix(extrinsics, into: &hasher)
//    }
//}

public extension Torus {
    
    /// The axis of the torus.
    var axis: simd_float3 {
        get { yAxis }
        set { yAxis = newValue }
    }
    
    /// The center position of the torus.
    var center: simd_float3 {
        get { position }
        set { position = newValue }
    }
}

internal extension Torus {
    
    init(from result: FindTorusResult) {
        self.init(meanRadius: result.meanRadius, tubeRadius: result.tubeRadius,
                  extrinsics: .extrinsics(yAxis: result.normal, position: result.center))
    }
}

public extension Torus {
    
    /// Rotates the model space, so that the torus's `axis` is as close as possible to the `upwardDirection`.
    mutating func align(relativeTo upwardDirection: simd_float3 = .init(0, 1, 0)) {
        
        if dot(axis, upwardDirection) < 0 {
            // means upside down, flip vertically.
            xAxis *= -1
            axis *= -1
        }
    }
    
    /// Rotates the model space, so that the torus's `axis` is as close as possible to the `upwardDirection`.
    func aligned(relativeTo upwardDirection: simd_float3 = .init(0, 1, 0)) -> Torus {
        var this = self
        this.align(relativeTo: upwardDirection)
        return this
    }
}
