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
    
    /// The 4x4 matrix that contains the sphere's orientation and position.
    public var extrinsics: simd_float4x4
    
    /// Initializes `Sphere` with `radius` and extrinsic parameters (`extrinsics`.)
    public init(radius: Float, extrinsics: simd_float4x4) {
        self.radius = radius
        self.extrinsics = extrinsics
    }
}

extension Sphere: Hashable, Codable {
    
    enum CodingKeys: MatrixCodingKey {
        case radius
        case column0, column1, column2, column3
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let radius = try container.decode(Float.self, forKey: .radius)
        let extrinsics = try decodeMatrix(from: container)
        self.init(radius: radius, extrinsics: extrinsics)
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(radius, forKey: .radius)
        try encodeMatrix(extrinsics, to: &container)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(radius)
        combineMatrix(extrinsics, into: &hasher)
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
