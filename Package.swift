// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VRCSwiftTraverse",
    products: [
        .library(
            name: "VRCSwiftTraverse",
            targets: ["VRCSwiftTraverse"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/SwiftyJSON/SwiftyJSON",
            Package.Dependency.Requirement.branch("master"))
    ],
    targets: [
        .target(
            name: "VRCSwiftTraverse",
            dependencies: ["SwiftyJSON"]),
        .testTarget(
            name: "VRCSwiftTraverseTests",
            dependencies: ["VRCSwiftTraverse"]),
    ]
)
