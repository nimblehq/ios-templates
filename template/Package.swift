// swift-tools-version: 6.0
@preconcurrency import PackageDescription

#if TUIST
    import struct ProjectDescription.PackageSettings

    let packageSettings = PackageSettings(
        productTypes: [:]
    )
#endif

let package = Package(
    name: "Dependencies",
    dependencies: [
        // Backend
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.10.0"),
        .package(url: "https://github.com/nimblehq/JSONMapper.git", from: "1.1.1"),
        
        // UI
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.12.0"),
        
        // Storage
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "4.2.2"),
        
        // Tools
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "11.15.0"),
        .package(url: "https://github.com/nimblehq/NimbleExtension.git", branch: "master"),
        // Note: R.swift is a code generation tool, not a library dependency
        // .package(url: "https://github.com/mac-cain13/R.swift.git", from: "7.0.0"),
        .package(url: "https://github.com/hmlongco/Factory.git", from: "2.5.0"),
        
        // Testing
        .package(url: "https://github.com/Quick/Quick.git", from: "7.6.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "13.8.0"),
        .package(url: "https://github.com/AliSoftware/OHHTTPStubs.git", from: "9.1.0"), // Provides OHHTTPStubsSwift product
    ]
)

