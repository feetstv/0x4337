// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "0x4337",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(url: "https://github.com/DiscordBM/DiscordBM", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.1.4")),
        .package(url: "https://github.com/coffmark/AccessAssociatedValue", .upToNextMajor(from: "0.1.0"))
        ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "0x4337",
            dependencies: [
                "DiscordBM",
                .product(name: "Collections", package: "swift-collections"),
                "AccessAssociatedValue"
            ]
        ),
    ]
)
