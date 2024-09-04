// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "STTextView",
    platforms: [.macOS(.v12), .iOS(.v16), .macCatalyst(.v16)],
    products: [
        .library(
            name: "STTextView",
            targets: ["STTextView", "STTextViewSwiftUI"]
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
                .target(name: "STTextViewAppKit"),
                .target(name: "STTextViewCommon"),
                
                    .target(name: "STTextViewSwiftUIAppKit"),
                
                    .target(name: "STObjCLandShim", condition: .when(platforms: [.macOS])),
                .product(name: "STTextKitPlus", package: "STTextKitPlus"),
                .product(name: "CoreTextSwift", package: "CoreTextSwift")
                
            ]
        ),
        .target(
            name: "STTextViewCommon",
            dependencies: [
                .product(name: "STTextKitPlus", package: "STTextKitPlus")
            ]
        ),
        
            .target(
                name: "STObjCLandShim",
                publicHeadersPath: "include"
            ),
        .testTarget(
            name: "STTextViewAppKitTests",
            dependencies: [
                .target(name: "STTextViewAppKit", condition: .when(platforms: [.macOS]))
            ]
        ),
    ]
)
