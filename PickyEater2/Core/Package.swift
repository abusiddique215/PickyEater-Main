// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PickyEater2Core",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "PickyEater2Core",
            targets: ["PickyEater2Core"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.1"),
    ],
    targets: [
        .target(
            name: "PickyEater2Core",
            dependencies: ["Alamofire"],
            path: "Sources"
        ),
        .testTarget(
            name: "PickyEater2CoreTests",
            dependencies: ["PickyEater2Core"],
            path: "Tests"
        ),
    ]
) 