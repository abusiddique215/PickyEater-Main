// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PickyEater2",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "PickyEater2",
            targets: ["PickyEater2"]
        ),
    ],
    dependencies: [
        // Add any external dependencies here
    ],
    targets: [
        .target(
            name: "PickyEater2",
            dependencies: [],
            path: "PickyEater2"
        ),
        .testTarget(
            name: "PickyEater2Tests",
            dependencies: ["PickyEater2"],
            path: "PickyEater2Tests"
        )
    ]
)
