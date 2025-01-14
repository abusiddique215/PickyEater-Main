// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PickyEater2",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "PickyEater2",
            targets: ["PickyEater2UI"]
        ),
    ],
    dependencies: [
        // Local Core Package
        .package(path: "PickyEater2/Core"),
        
        // Networking
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.1"),

        // Image Loading and Caching
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.10.1"),

        // In-App Purchases
        .package(url: "https://github.com/RevenueCat/purchases-ios.git", from: "4.31.6"),
    ],
    targets: [
        // UI Layer
        .target(
            name: "PickyEater2UI",
            dependencies: [
                .product(name: "PickyEater2Core", package: "Core"),
                "Kingfisher",
            ],
            path: "PickyEater2/UI"
        ),

        // Infrastructure Layer
        .target(
            name: "PickyEater2Infrastructure",
            dependencies: [
                .product(name: "PickyEater2Core", package: "Core"),
            ],
            path: "PickyEater2/Infrastructure"
        ),

        // Features Layer
        .target(
            name: "PickyEater2Features",
            dependencies: [
                .product(name: "PickyEater2Core", package: "Core"),
                "PickyEater2UI",
                "RevenueCat",
            ],
            path: "PickyEater2/Features"
        ),

        // Main App Target
        .target(
            name: "PickyEater2",
            dependencies: [
                .product(name: "PickyEater2Core", package: "Core"),
                "PickyEater2UI",
                "PickyEater2Infrastructure",
                "PickyEater2Features",
            ],
            path: "PickyEater2",
            exclude: [
                "Core",
                "UI",
                "Infrastructure",
                "Features",
                "Tests",
            ],
            resources: [
                .process("Resources"),
            ]
        ),

        // Test Targets
        .testTarget(
            name: "PickyEater2Tests",
            dependencies: ["PickyEater2"],
            path: "PickyEater2/Tests",
            exclude: ["PickyEater2UITests.swift", "PickyEater2UITestsLaunchTests.swift"]
        ),
        .testTarget(
            name: "PickyEater2UITests",
            dependencies: ["PickyEater2"],
            path: "PickyEater2/Tests",
            sources: ["PickyEater2UITests.swift", "PickyEater2UITestsLaunchTests.swift"]
        ),
    ]
)
