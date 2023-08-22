// swift-tools-version: 5.7.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "iOSTemplateMaker",
    products: [
        .executable(
            name: "iOSTemplateMaker",
            targets: ["iOSTemplateMaker"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-argument-parser.git", 
            from: "1.0.0"
        ),
    ],
    targets: [
        .executableTarget(
            name: "iOSTemplateMaker",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
    ]
)
