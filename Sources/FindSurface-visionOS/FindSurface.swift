//
//  FindSurface.swift
//
//
//  Created by CurvSurf-SGKim on 6/17/24.
//

import Foundation
import simd

import FindSurfaceFramework

@globalActor
fileprivate actor FindSurfaceActor {
    static let shared = FindSurfaceActor()
}

internal typealias RawFindSurface = FindSurfaceFramework.FindSurface

/// A FindSurface object that contains the necessary context and allows you to invoke its operation.
///
/// Since FindSurface does not support concurrent operations currently, due to its internal implementation's limitations,
/// it maintains only a single context (singleton) and keeps you from invoking it multiple times until it finishes the ongoing operation.
@Observable
public final class FindSurface {
    
    public static let instance = FindSurface()
    private init() {}
    
    public enum Result {
        
        /// Contains a geometric information about a plane, its inlier points, and the RMS errror.
        case foundPlane(Plane, [simd_float3], Float)
        
        /// Contains a geometric information about a sphere, its inlier points, and the RMS error.
        case foundSphere(Sphere, [simd_float3], Float)
        
        /// Contains a geometric information about a cylinder, its inlier points, and the RMS error.
        case foundCylinder(Cylinder, [simd_float3], Float)
        
        /// Contains a geometric information about a conical frustum, its inlier points, and the RMS error.
        case foundCone(Cone, [simd_float3], Float)
        
        /// Contains a geometric information about a torus, its inlier points, and the RMS error.
        case foundTorus(Torus, [simd_float3], Float)
        
        /// Indicates that FindSurface couldn't detect any surface from the given pointcloud, yielding the RMS error at the failed moment.
        case none(Float)
    }
    
    public enum Failure: Error {
        
        /// Means that FindSurface couldn't allocate a necessary memory block.
        case memoryAllocationFailure
        
        case invalidArgument(String)
        
        case invalidOperation(String)
        
        fileprivate init(_ rawError: RawFindSurface.FindSurfaceError) {
            switch rawError {
            case .failedMemoryAllocation:               self = .memoryAllocationFailure
            case let .invalidArgument(description):     self = .invalidArgument(description)
            case let .invalidOperation(description):    self = .invalidOperation(description)
            @unknown default:                           fatalError()
            }
        }
    }
    
    private let context = RawFindSurface.sharedInstance()
    
    /// The feature type to detect.
    public var targetFeature: FeatureType = .plane
    
    /// The a *priori* root-mean-squared error (in meters) of the measurement points.
    ///
    /// In most cases, the value of this error is determined by the scanner devices
    /// that provide the points, but it may vary depending on the scan distance.
    ///
    /// Specifically, one can estimate the a priori error by getting a linear error model
    /// as a function of distance such as `a + b * distance`
    /// where `a` is a base noise level and `b` is a coefficient of increase in noise level
    /// according to measuring distance.
    ///
    /// This value is to be used to validate the results of FindSurface
    /// by checking whether the a posteriori RMS error is not large enough
    /// (e.g., smaller than 1.5 times this a priori value).
    /// One of the reasons for getting large a posteriori RMS errors is due to the model error;
    /// the assumed surface model does not represent the measurement points well.
    ///
    /// - Tip: You may set this value to an approximated value (about 2x of the actual error) or a heuristically estimated value.
    ///
    /// - Note: This property must be set to a positive value (non-zero).
    public var measurementAccuracy: Float = 0
    
    /// The average distance (in meters) between points.
    ///
    /// `meanDistance` is determined by the scanner device's resolution and its scan distance.
    /// This value is to be used to validate the results of FindSurface
    /// by checking the point density of inlier points.
    ///
    /// - Tip: It is recommended to set this value to a 2~5 times higher value of the actual one
    /// because the inlier points will have lower point density than that of input points.
    ///
    /// - Note: This property must be set to a positive value (non-zero).
    public var meanDistance: Float = 00
    
    /// The radius (in meters) of a seed region around the seed point where FindSurface starts searching for the surface.
    ///
    /// This value depends on the size of the geometry that you're interested in.
    ///
    /// - Note: This property must be set to a positive value (non-zero).
    public var seedRadius: Float = 0.30
    
    /// The tendency for the algorithm to spread its search space in tangent direction of the surface to be sought.
    ///
    /// A larger plane or a longer cylinder might be detected as you set it to a higher value, and vice versa.
    ///
    /// - Note: `lateralExtension` has no influence to searching for a sphere or a torus.
    public var lateralExtension: SearchLevel = .lv5
    
    /// The tendency for the algorithm to thicken/thin its search space in normal direction of the surface to be sought.
    ///
    /// If the measurement points are relatively accurate/inaccurate,
    /// the most/least points might be considered as inlier points
    /// as you set it to a higher/lower value (level of inlier/outlier inclusion/exclusion).
    ///
    /// - Tip: It is recommended not to set it to a lower/higher value for relatively accurate/inaccurate measurement points.
    public var radialExpansion: SearchLevel = .lv5
    
    /// Options to allow FindSurface to convert geometries automatically according to their geometric topology.
    ///
    /// In the mathematical models of the geometric surfaces that the algorithm of FindSurface builds,
    /// there are some special relations between the surfaces in terms of geometric topology.
    /// For example, a cone (conical frustum) that has the same radii at both its top and bottom is actually a cylinder.
    /// After the model converges to a specific surface type, this feature, if enabled, automatically converts the type
    /// according to the relations.
    ///
    /// Options include:
    /// - `.coneToCylinder`: converts a cone (conical frustum) that has the same radii at both its top and bottom into a cylinder;
    /// - `.torusToSphere`: converts a degenerate torus (a double-covered sphere), of which mean radius is zero, into a sphere (this gif will help you understand what it is);
    /// - `.torusToCylinder`: converts a torus that has an infinite mean radius into a cylinder;
    public var conversionOptions: ConversionOptions = .init(ConversionOptions.allCases)
    
    private var task: Task<Result, Error>? = nil
    
    /// Invokes FindSurface if available.
    ///
    /// Due to the nature of FindSurface's internal implementation, this method internally check if the previous invocation is finished,
    /// quickly returning `nil` if one haven't finished yet.
    ///
    /// - returns: `Result` if FindSurface was available, `nil` otherwise.
    public func perform(pickPoint: () async -> ([simd_float3], Int)?) async throws -> Result? {
        
        guard task == nil else { return nil }
        
        guard let (pointcloud, index) = await pickPoint() else {
            return nil
        }
        task = Task {
            do {
                return try await self.run(pointcloud, index)
            } catch {
                throw error
            }
        }
        
        defer {
            task = nil
        }
        return try await task?.value
    }
    
    @FindSurfaceActor
    private func run(_ pointcloud: [simd_float3], _ index: Int) async throws -> Result {
        
        context.measurementAccuracy = measurementAccuracy
        context.meanDistance = meanDistance
        context.lateralExtension = .init(lateralExtension)
        context.radialExpansion = .init(radialExpansion)
        context.smartConversionOptions = .init(conversionOptions)
        
        do {
            try context.setPointCloudData(pointcloud,
                                          pointCount: pointcloud.count,
                                          pointStride: MemoryLayout<simd_float3>.stride,
                                          useDoublePrecision: false)
        } catch {
            guard let error = error as? RawFindSurface.FindSurfaceError else { throw error }
            switch error {
            case .failedMemoryAllocation:
                throw Failure.memoryAllocationFailure
            case let .invalidArgument(reason):
                throw Failure.invalidArgument(reason)
            case let .invalidOperation(reason):
                throw Failure.invalidOperation(reason)
            default: break
            }
        }
        
        do {
            var rmsError: Float = 0
            
            guard let result = try context.findSurface(featureType: .init(targetFeature),
                                                       seedIndex: index,
                                                       seedRadius: seedRadius,
                                                       rmsError: &rmsError,
                                                       requestInlierFlags: true) else {
                return .none(rmsError)
            }
            guard targetFeature == .any ||
                    result.type == .init(targetFeature) ||
                    (targetFeature == .torus && result.type == .sphere && conversionOptions.contains(.torusToSphere)) ||
                    (targetFeature == .torus && result.type == .cylinder && conversionOptions.contains(.torusToCylinder)) ||
                    (targetFeature == .cone && result.type == .cylinder && conversionOptions.contains(.coneToCylinder)) else {
                return .none(rmsError)
            }
            
            let inlierFlags = result.inlierFlags!
            let inliers = pointcloud.enumerated().filter { index, _ in
                inlierFlags.isInlier(at: index)
            }.map { $0.element }
            
            switch result.type {
            case .plane:
                let plane = Plane(from: result.getAsPlaneResult()!)
                return .foundPlane(plane, inliers, rmsError)
                
            case .sphere:
                let sphere = Sphere(from: result.getAsSphereResult()!)
                return .foundSphere(sphere, inliers, rmsError)
                
            case .cylinder:
                let cylinder = Cylinder(from: result.getAsCylinderResult()!)
                return .foundCylinder(cylinder, inliers, rmsError)
                
            case .cone:
                let cone = Cone(from: result.getAsConeResult()!)
                return .foundCone(cone, inliers, rmsError)
                
            case .torus:
                let torus = Torus(from: result.getAsTorusResult()!)
                return .foundTorus(torus, inliers, rmsError)
                
            case .any: fallthrough
            @unknown default: fatalError()
            }
        } catch let error as RawFindSurface.FindSurfaceError {
            throw Failure(error)
        }
    }
}
