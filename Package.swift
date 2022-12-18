// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TCABoundaries",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "TCABoundaries",
            targets: [
                "TCABoundaries"
            ]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture.git",
            from: "0.47.2"
        ),
    ],
    targets: [
        .target(
            name: "TCABoundaries",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .testTarget(
            name: "TCABoundariesTests",
            dependencies: [
                "TCABoundaries"
            ]
        ),
    ]
)
