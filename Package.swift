// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "PickyEater2",
    platforms: [
        .macOS(.v12),
    ],
    targets: [
        .executableTarget(
            name: "PickyEater2",
            path: "Sources"
        ),
    ]
)
