// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RouletteFeature",
    platforms: [.iOS(SupportedPlatform.IOSVersion.v16), .macOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "RouletteFeature",
            targets: ["RouletteFeature"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.53.2"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "RouletteFeature",
            dependencies: [
                "Item",
                "UserDefaultsClient",
                "Tutorial",
                "Request",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]),
        .target(
          name: "Item"
          
        ),
        .target(
          name: "Tutorial",
          dependencies: ["Utility"]
        ),
        .target(
          name: "Utility"
        ),
        .target(
          name: "Request",
          dependencies: [
            "Utility",
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            
          ]
        ),
        .target(
          name: "UserDefaultsClient",
          dependencies: [
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
          ]
        ),
        .testTarget(
            name: "RouletteFeatureTests",
            dependencies: ["RouletteFeature"]),
    ]
)
