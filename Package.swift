// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "MyApp",

    products: [
        .library(
            name: "MyApp",
            targets: ["MyApp"]
        )
    ],

    targets: [
        .target(
            name: "MyApp"
        ),

        .testTarget(
            name: "MyAppTests",
            dependencies: ["MyApp"]
        )
    ]
)