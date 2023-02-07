// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Photo",
    platforms: [.iOS(.v16), .macOS(.v13), .watchOS(.v9)],
    products: [
        // Features
        .library(name: "FeatureApp", targets: ["FeatureApp"]),
        .library(name: "FeatureVote", targets: ["FeatureVote"]),
        .library(name: "ComponentLibrary", targets: ["ComponentLibrary"]),
        
        // Services
        .library(name: "ServiceImage", targets: ["ServiceImage"]),
        
        // Utilities
        .library(name: "Models", targets: ["Models"]),
        .library(name: "NavigationHelpers", targets: ["NavigationHelpers"]),
        .library(name: "Networking", targets: ["Networking"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", .upToNextMajor(from: "0.50.0")),
        .package(url: "https://github.com/lorenzofiamingo/swiftui-cached-async-image", branch: "main"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        
        // Features
        .target(name: "FeatureApp", dependencies: [
            "ComponentLibrary",
            "FeatureVote",
            "NavigationHelpers",
            "ServiceImage",
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        ]),
        .target(name: "FeatureVote", dependencies: [
            "ComponentLibrary",
            "NavigationHelpers",
            "ServiceImage",
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        ]),
        .target(name: "ComponentLibrary", dependencies: [
            .product(name: "CachedAsyncImage", package: "swiftui-cached-async-image"),
        ]),
        
        // Services
        .target(name: "ServiceImage", dependencies: [
            "Models",
            "Networking",
        ]),
        
        // Utilities
        .target(name: "Networking", dependencies: [
            "Models",
        ]),
        .target(name: "Models", dependencies: []),
        .target(name: "NavigationHelpers", dependencies: [
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        ]),
        
        // Tests
        .testTarget(
            name: "PhotoTests",
            dependencies: [
                "FeatureApp",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]),
    ]
)
