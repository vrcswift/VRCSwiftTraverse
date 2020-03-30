// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "VRCSwiftTraverse",
    platforms: [
        .macOS(.v10_10), .iOS(.v8)
    ],
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
    ],
    swiftLanguageVersions: [.v5]
)
