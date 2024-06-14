//
//  FindSurface.h
//  FindSurfaceFramework
//

#ifndef _FIND_SURFACE_H_
#define _FIND_SURFACE_H_

#import <Foundation/Foundation.h>
#import <simd/simd.h>

typedef NS_ENUM(NSInteger, FindSurfaceErrorCode)
{
    FindSurfaceErrorCodeNoError          =  0,
    FindSurfaceErrorCodeOutOfMemory      = -1,
    FindSurfaceErrorCodeInvalidOperation = -2,
    FindSurfaceErrorCodeInvalidValue     = -3
} NS_SWIFT_NAME(FindSurface.ErrorCode);

typedef NS_ENUM(unsigned, FindSurfaceFeatureType)
{
    FindSurfaceFeatureTypeAny      = 0,
    FindSurfaceFeatureTypePlane    = 1,
    FindSurfaceFeatureTypeSphere   = 2,
    FindSurfaceFeatureTypeCylinder = 3,
    FindSurfaceFeatureTypeCone     = 4,
    FindSurfaceFeatureTypeTorus    = 5
} NS_SWIFT_NAME(FindSurface.FeatureType);

typedef NS_ENUM(unsigned, FindSurfaceSearchLevel)
{
    FindSurfaceSearchLevelOff NS_SWIFT_NAME(off)  = 0 ,
    FindSurfaceSearchLevel1   NS_SWIFT_NAME(lv1)  = 1, FindSurfaceSearchLevelModerate NS_SWIFT_NAME(moderate) = 1,
    FindSurfaceSearchLevel2   NS_SWIFT_NAME(lv2)  = 2,
    FindSurfaceSearchLevel3   NS_SWIFT_NAME(lv3)  = 3,
    FindSurfaceSearchLevel4   NS_SWIFT_NAME(lv4)  = 4,
    FindSurfaceSearchLevel5   NS_SWIFT_NAME(lv5)  = 5, FindSurfaceSearchLevelDefault NS_SWIFT_NAME(default) = 5,
    FindSurfaceSearchLevel6   NS_SWIFT_NAME(lv6)  = 6,
    FindSurfaceSearchLevel7   NS_SWIFT_NAME(lv7)  = 7,
    FindSurfaceSearchLevel8   NS_SWIFT_NAME(lv8)  = 8,
    FindSurfaceSearchLevel9   NS_SWIFT_NAME(lv9)  = 9,
    FindSurfaceSearchLevel10  NS_SWIFT_NAME(lv10) = 10, FindSurfaceSearchLevelRadical NS_SWIFT_NAME(radical) = 10
} NS_SWIFT_NAME(FindSurface.SearchLevel);

typedef NS_OPTIONS(unsigned, FindSurfaceSmartConversionOption)
{
    FindSurfaceSmartConversionOptionNone           = 0,
    FindSurfaceSmartConversionOptionCone2Cylinder  = 1 << 0,
    FindSurfaceSmartConversionOptionTorus2Sphere   = 1 << 1,
    FindSurfaceSmartConversionOptionTorus2Cylinder = 1 << 2
} NS_SWIFT_NAME(FindSurface.SmartConversionOption);

//
// class FindSurfaceInlierFlags
//

NS_SWIFT_NAME(FindSurface.InlierFlags)
@interface FindSurfaceInlierFlags : NSObject
@property(readonly) NSInteger count;
@property(readonly) NSInteger inlierCount;
@property(readonly) NSInteger outlierCount;
// Subscript
- (BOOL)objectAtIndexedSubscript:(NSInteger)idx;
// Member Functions
- (BOOL)isInlierAt:(NSInteger)index;
- (BOOL)isOutlierAt:(NSInteger)index;
@end

//
// class FindSurfaceResult
//

@class FindPlaneResult;
@class FindSphereResult;
@class FindCylinderResult;
@class FindConeResult;
@class FindTorusResult;

@interface FindSurfaceResult : NSObject
@property(readonly)           FindSurfaceFeatureType   type;
@property(readonly)           float                    rmsError;
@property(readonly, nullable) FindSurfaceInlierFlags * inlierFlags;
// casting to each result type
- (nullable FindPlaneResult *)    getAsPlaneResult;
- (nullable FindSphereResult *)   getAsSphereResult;
- (nullable FindCylinderResult *) getAsCylinderResult;
- (nullable FindConeResult *)     getAsConeResult;
- (nullable FindTorusResult *)    getAsTorusResult;
@end

@interface FindPlaneResult : FindSurfaceResult
// basic
@property(readonly) vector_float3 lowerLeft;
@property(readonly) vector_float3 lowerRight;
@property(readonly) vector_float3 upperRight;
@property(readonly) vector_float3 upperLeft;
// calculated
@property(readonly) vector_float3 normal;
@property(readonly) vector_float3 center;
@end

@interface FindSphereResult : FindSurfaceResult
// basic
@property(readonly) vector_float3 center;
@property(readonly) float         radius;
@end

@interface FindCylinderResult : FindSurfaceResult
// basic
@property(readonly) vector_float3 bottom;
@property(readonly) vector_float3 top;
@property(readonly) float         radius;
// calculated
@property(readonly) vector_float3 axis; // bottom to top
@property(readonly) vector_float3 center;
@property(readonly) float         height;
@end

@interface FindConeResult : FindSurfaceResult
// basic
@property(readonly) vector_float3 bottom;
@property(readonly) vector_float3 top;
@property(readonly) float         bottomRadius;
@property(readonly) float         topRadius;
// calculated
@property(readonly) vector_float3 axis; // bottom to top
@property(readonly) vector_float3 center;
@property(readonly) float         height;
@end

@interface FindTorusResult : FindSurfaceResult
// basic
@property(readonly) vector_float3 center;
@property(readonly) vector_float3 normal;
@property(readonly) float         meanRadius;
@property(readonly) float         tubeRadius;
@end

//
// class FindSurface
//

@interface FindSurface : NSObject

// Singleton
+ (nonnull instancetype) sharedInstance;

// Algorithm Parameter Properties
@property(getter=getRadialExpansion,     setter=setRadialExpansion:)           FindSurfaceSearchLevel           radialExpansion;
@property(getter=getLateralExtension,    setter=setLateralExtension:)          FindSurfaceSearchLevel           lateralExtension;
@property(getter=getMeasurementAccuracy, setter=setMeasurementAccuracy:)       float                            measurementAccuracy;
@property(getter=getMeanDistance,        setter=setMeanDistance:)              float                            meanDistance;
@property(getter=getSmartConversionOptions, setter=setSmartConversionOptions:) FindSurfaceSmartConversionOption smartConversionOptions;

// Algorithm Optional Setting
- (void) setSmartConversionOptions: (FindSurfaceSmartConversionOption) options;
- (FindSurfaceSmartConversionOption) getSmartConversionOptions;

// Algorithm (Search Level) Parameters
- (void) setRadialExpansion: (FindSurfaceSearchLevel)level;
- (FindSurfaceSearchLevel) getRadialExpansion;

- (void) setLateralExtension: (FindSurfaceSearchLevel)level;
- (FindSurfaceSearchLevel) getLateralExtension;

// Set Target Point Cloud Data & it's Description
- (void) setMeasurementAccuracy: (float)accuracy;
- (float) getMeasurementAccuracy;

- (void) setMeanDistance: (float)distance;
- (float) getMeanDistance;

- (BOOL) setPointCloudData: (nonnull const void *) data
                pointCount: (NSInteger) count
        useDoublePrecision: (bool) useDoublePrecision
          didFailWithError: (NSError * _Nullable __autoreleasing * _Nullable) error
NS_REFINED_FOR_SWIFT;

- (BOOL) setPointCloudData: (nonnull const void *) data
                pointCount: (NSInteger) count
               pointStride: (NSInteger) stride
        useDoublePrecision: (bool) useDoublePrecision
          didFailWithError: (NSError * _Nullable __autoreleasing * _Nullable) error
NS_REFINED_FOR_SWIFT;

- (void) cleanUp;

// Run FindSurface
- (nullable FindSurfaceResult *) findPlaneFromSeedIndex: (NSInteger) index 
                                          andSeedRadius: (float) touchRadius
                                               rmsError: (float * _Nonnull) rmsError
                                       didFailWithError: (NSError * _Nullable __autoreleasing * _Nullable)error
NS_REFINED_FOR_SWIFT;
- (nullable FindSurfaceResult *) findPlaneFromSeedIndex: (NSInteger) index 
                                          andSeedRadius: (float) touchRadius 
                                       didFailWithError: (NSError * _Nullable __autoreleasing * _Nullable)error
NS_REFINED_FOR_SWIFT;
- (nullable FindSurfaceResult *) findSphereFromSeedIndex: (NSInteger) index 
                                           andSeedRadius: (float) touchRadius
                                                rmsError: (float * _Nonnull) rmsError
                                        didFailWithError: (NSError * _Nullable __autoreleasing * _Nullable)error
NS_REFINED_FOR_SWIFT;
- (nullable FindSurfaceResult *) findSphereFromSeedIndex: (NSInteger) index 
                                           andSeedRadius: (float) touchRadius 
                                        didFailWithError: (NSError * _Nullable __autoreleasing * _Nullable)error
NS_REFINED_FOR_SWIFT;
- (nullable FindSurfaceResult *) findCylinderFromSeedIndex: (NSInteger) index 
                                             andSeedRadius: (float) touchRadius
                                                  rmsError: (float * _Nonnull) rmsError
                                          didFailWithError: (NSError * _Nullable __autoreleasing * _Nullable)error
NS_REFINED_FOR_SWIFT;
- (nullable FindSurfaceResult *) findCylinderFromSeedIndex: (NSInteger) index 
                                             andSeedRadius: (float) touchRadius
                                          didFailWithError: (NSError * _Nullable __autoreleasing * _Nullable)error
NS_REFINED_FOR_SWIFT;
- (nullable FindSurfaceResult *) findConeFromSeedIndex: (NSInteger) index 
                                         andSeedRadius: (float) touchRadius
                                              rmsError: (float * _Nonnull) rmsError
                                      didFailWithError: (NSError * _Nullable __autoreleasing * _Nullable)error
NS_REFINED_FOR_SWIFT;
- (nullable FindSurfaceResult *) findConeFromSeedIndex: (NSInteger) index 
                                         andSeedRadius: (float) touchRadius
                                      didFailWithError: (NSError * _Nullable __autoreleasing * _Nullable)error
NS_REFINED_FOR_SWIFT;
- (nullable FindSurfaceResult *) findTorusFromSeedIndex: (NSInteger) index 
                                          andSeedRadius: (float) touchRadius
                                               rmsError: (float * _Nonnull) rmsError
                                       didFailWithError: (NSError * _Nullable __autoreleasing * _Nullable)error
NS_REFINED_FOR_SWIFT;
- (nullable FindSurfaceResult *) findTorusFromSeedIndex: (NSInteger) index 
                                          andSeedRadius: (float) touchRadius 
                                       didFailWithError: (NSError * _Nullable __autoreleasing * _Nullable)error
NS_REFINED_FOR_SWIFT;

- (nullable FindSurfaceResult *) findPlaneFromSeedIndex: (NSInteger) index 
                                          andSeedRadius: (float) touchRadius
                                     requestInlierFlags: (BOOL) reqFlags 
                                               rmsError: (float * _Nonnull) rmsError 
                                       didFailWithError: (NSError * _Nullable __autoreleasing * _Nullable)error
NS_REFINED_FOR_SWIFT;
- (nullable FindSurfaceResult *) findPlaneFromSeedIndex: (NSInteger) index 
                                          andSeedRadius: (float) touchRadius 
                                     requestInlierFlags: (BOOL) reqFlags
                                       didFailWithError: (NSError * _Nullable __autoreleasing * _Nullable)error
NS_REFINED_FOR_SWIFT;
- (nullable FindSurfaceResult *) findSphereFromSeedIndex: (NSInteger) index 
                                           andSeedRadius: (float) touchRadius
                                      requestInlierFlags: (BOOL) reqFlags
                                                rmsError: (float * _Nonnull) rmsError
                                        didFailWithError: (NSError * _Nullable __autoreleasing * _Nullable)error
NS_REFINED_FOR_SWIFT;
- (nullable FindSurfaceResult *) findSphereFromSeedIndex: (NSInteger) index 
                                           andSeedRadius: (float) touchRadius
                                      requestInlierFlags: (BOOL) reqFlags
                                        didFailWithError: (NSError * _Nullable __autoreleasing * _Nullable)error
NS_REFINED_FOR_SWIFT;
- (nullable FindSurfaceResult *) findCylinderFromSeedIndex: (NSInteger) index 
                                             andSeedRadius: (float) touchRadius
                                        requestInlierFlags: (BOOL) reqFlags
                                                  rmsError: (float * _Nonnull) rmsError
                                          didFailWithError: (NSError * _Nullable __autoreleasing * _Nullable)error
NS_REFINED_FOR_SWIFT;
- (nullable FindSurfaceResult *) findCylinderFromSeedIndex: (NSInteger) index 
                                             andSeedRadius: (float) touchRadius
                                        requestInlierFlags: (BOOL) reqFlags
                                          didFailWithError: (NSError * _Nullable __autoreleasing * _Nullable)error
NS_REFINED_FOR_SWIFT;
- (nullable FindSurfaceResult *) findConeFromSeedIndex: (NSInteger) index 
                                         andSeedRadius: (float) touchRadius
                                    requestInlierFlags: (BOOL) reqFlags
                                             rmsError: (float * _Nonnull) rmsError
                                      didFailWithError: (NSError * _Nullable __autoreleasing * _Nullable)error
NS_REFINED_FOR_SWIFT;
- (nullable FindSurfaceResult *) findConeFromSeedIndex: (NSInteger) index 
                                         andSeedRadius: (float) touchRadius
                                    requestInlierFlags: (BOOL) reqFlags
                                      didFailWithError: (NSError * _Nullable __autoreleasing * _Nullable)error
NS_REFINED_FOR_SWIFT;
- (nullable FindSurfaceResult *) findTorusFromSeedIndex: (NSInteger) index 
                                          andSeedRadius: (float) touchRadius
                                     requestInlierFlags: (BOOL) reqFlags
                                               rmsError: (float * _Nonnull) rmsError
                                       didFailWithError: (NSError * _Nullable __autoreleasing * _Nullable)error
NS_REFINED_FOR_SWIFT;
- (nullable FindSurfaceResult *) findTorusFromSeedIndex: (NSInteger) index 
                                          andSeedRadius: (float) touchRadius
                                     requestInlierFlags: (BOOL) reqFlags
                                       didFailWithError: (NSError * _Nullable __autoreleasing * _Nullable)error
NS_REFINED_FOR_SWIFT;

- (nullable FindSurfaceResult *) findSurface: (FindSurfaceFeatureType) type 
                               fromSeedIndex: (NSInteger) index
                               andSeedRadius: (float) touchRadius
                                    rmsError: (float * _Nonnull) rmsError
                            didFailWithError: (NSError * _Nullable __autoreleasing * _Nullable)error
NS_REFINED_FOR_SWIFT;
- (nullable FindSurfaceResult *) findSurface: (FindSurfaceFeatureType) type 
                               fromSeedIndex: (NSInteger) index
                               andSeedRadius: (float) touchRadius
                            didFailWithError: (NSError * _Nullable __autoreleasing * _Nullable)error
NS_REFINED_FOR_SWIFT;

- (nullable FindSurfaceResult *) findSurface: (FindSurfaceFeatureType) type 
                               fromSeedIndex: (NSInteger) index
                               andSeedRadius: (float) touchRadius
                          requestInlierFlags: (BOOL) reqFlags
                                    rmsError: (float * _Nonnull) rmsError
                            didFailWithError: (NSError * _Nullable __autoreleasing * _Nullable)error
NS_REFINED_FOR_SWIFT;
- (nullable FindSurfaceResult *) findSurface: (FindSurfaceFeatureType) type 
                               fromSeedIndex: (NSInteger) index
                               andSeedRadius: (float) touchRadius
                          requestInlierFlags: (BOOL) reqFlags
                            didFailWithError: (NSError * _Nullable __autoreleasing * _Nullable)error
NS_REFINED_FOR_SWIFT;


@end


#endif // _FIND_SURFACE_H_
