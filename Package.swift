// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FestivalsAPI",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
    ],
    products: [
        .library(
            name: "FestivalsAPI",
            targets: ["FestivalsAPI"]),
    ],
    targets: [
        .target(
            name: "FestivalsAPI",
            resources: [.process("Resources")]),
        .testTarget(
            name: "FestivalsAPITests",
            dependencies: ["FestivalsAPI"],
            resources: [.process("Certificates")]),
    ]
)
