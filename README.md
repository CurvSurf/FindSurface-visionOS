# FindSurface-visionOS

**Curv*Surf* FindSurface™ library package for visionOS (Swift)**

## Overview

**FindSurface-visionOS** is a Swift package of FindSurface™ library, of which interface is modified to allow you to use its functionalities.

## How to install

### Adding this package as a Dependency

You can import this package by adding the following line to the dependencies in your `Package.swift` file:

````
dependencies: [
    ...
    .package(utl: "https://github.com/CurvSurf/FindSurface-visionOS", from: "1.0.0")
],
targets: [
    .target(name: "<target>", dependencies: [
        ...
        "FindSurface-visionOS"
    ]),
    ...
]
````

Then, add `import FindSurface_visionOS` (note that it is not hyphenated, but underscored in the middle of the words.)

### Using the XCFramework without the wrapper

This package is a wrapper containing the visionOS version (including the simulator) of the FindSurface XCFramework. You can also refer to the source code of this package to use the framework directly. In that case, import `FindSurfaceFramework` instead.

## About License

You may use the source code of this package freely under MIT license, as the license file stated, except for `FindSurfaceFramework`, which is the core of the package.

About the framework, refer to the following statement:

````
Copyright (c) 2024 CurvSurf, Inc. All rights reserved.

The framework `FindSurfaceFramework`'s ownership is solely on CurvSurf, Inc. 
and anyone can use it for non-commercial purposes. 
Contact to support@curvsurf.com for commercial use of the library.
````

