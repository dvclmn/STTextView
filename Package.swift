// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "STTextView",
    platforms: [.macOS(.v12), .iOS(.v16), .macCatalyst(.v16)],
    products: [
        .library(
            name: "STTextView",
            targets: ["STTextView"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/krzyzanowskim/STTextKitPlus", from: "0.1.3"),
        .package(url: "https://github.com/krzyzanowskim/CoreTextSwift", from: "0.2.0")
    ],
    targets: [
        .target(
            name: "STTextView",
            dependencies: [
                .target(name: "STObjCLandShim"),
                .product(name: "STTextKitPlus", package: "STTextKitPlus"),
                .product(name: "CoreTextSwift", package: "CoreTextSwift")
            ]
        ),
        .target(
            name: "STObjCLandShim",
            publicHeadersPath: "include"
        ),
        .testTarget(
            name: "STTextViewAppKitTests",
            dependencies: [
                .target(name: "STTextView")
            ]
        ),
    ]
)
