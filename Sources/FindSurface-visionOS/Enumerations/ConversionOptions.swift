//
//  ConversionOptions.swift
//
//
//  Created by CurvSurf-SGKim on 6/17/24.
//

import Foundation

import FindSurfaceFramework

public struct ConversionOptions: OptionSet, CaseIterable {
    
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let coneToCylinder = ConversionOptions(rawValue: 1 << 0)
    public static let torusToSphere = ConversionOptions(rawValue: 1 << 1)
    public static let torusToCylinder = ConversionOptions(rawValue: 1 << 2)
    
    static public var allCases: [ConversionOptions] = [.coneToCylinder,
                                                       .torusToSphere,
                                                       .torusToCylinder]
}

internal extension ConversionOptions {
    
    init(_ rawValue: RawFindSurface.SmartConversionOption) {
        var options: ConversionOptions = []
        if rawValue.contains(.cone2Cylinder) {
            options.insert(.coneToCylinder)
        }
        if rawValue.contains(.torus2Sphere) {
            options.insert(.torusToSphere)
        }
        if rawValue.contains(.torus2Cylinder) {
            options.insert(.torusToCylinder)
        }
        self = options
    }
}

internal extension RawFindSurface.SmartConversionOption {
    
    init(_ options: ConversionOptions) {
        var rawOptions: RawFindSurface.SmartConversionOption = []
        if options.contains(.coneToCylinder) {
            rawOptions.insert(.cone2Cylinder)
        }
        if options.contains(.torusToSphere) {
            rawOptions.insert(.torus2Sphere)
        }
        if options.contains(.torusToCylinder) {
            rawOptions.insert(.torus2Cylinder)
        }
        self = rawOptions
    }
}
