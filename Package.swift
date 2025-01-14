// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "PickyEater2",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "PickyEater2Core",
            targets: ["PickyEater2Core"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.1"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.10.2"),
        .package(url: "https://github.com/RevenueCat/purchases-ios.git", from: "4.31.9"),
    ],
    targets: [
        .target(
            name: "PickyEater2Core",
            dependencies: [
                "Alamofire",
                "Kingfisher",
                .product(name: "RevenueCat", package: "purchases-ios"),
            ],
            path: "PickyEater2/Core"
        ),
        .testTarget(
            name: "PickyEater2Tests",
            dependencies: ["PickyEater2Core"],
            path: "PickyEater2Tests"
        ),
    ]
)
