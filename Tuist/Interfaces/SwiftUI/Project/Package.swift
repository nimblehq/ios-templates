// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "{PROJECT_NAME}",
    platforms: [
        .iOS(.v{TARGET_VERSION})
    ],
    products: [
        .library(
            name: "{PROJECT_NAME}",
            targets: ["{PROJECT_NAME}"]
        ),
    ],
    dependencies: [
        // UI
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.0.0"),
        
        // Networking / Backend
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.6.0"),
        .package(url: "https://github.com/nimblehq/JSONMapper.git", from: "1.1.1"),
        
        // Storage
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "4.2.2"),
        
        // Testing
        .package(url: "https://github.com/Quick/Quick.git", from: "7.0.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "12.0.0"),
        .package(url: "https://github.com/krzysztofzablocki/Sourcery.git", from: "2.0.0"),
        .package(url: "https://github.com/AliSoftware/OHHTTPStubs.git", from: "9.0.0"),
        .package(url: "https://github.com/kif-framework/KIF.git", from: "0.10.0"),
        
        // Tools
        .package(url: "https://github.com/nimblehq/NimbleExtension.git", branch: "master"),
        .package(url: "https://github.com/hmlongc/Factory.git", from: "2.2.0"),
        .package(url: "https://github.com/realm/SwiftLint.git", from: "0.54.0"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.0.0"),
        
        // Secrets
        .package(path: "ArkanaKeys/ArkanaKeys")
    ],
    targets: [
        .target(
            name: "{PROJECT_NAME}",
            dependencies: [
                "Kingfisher",
                "Alamofire",
                "JSONAPIMapper",
                "KeychainAccess",
                "NimbleExtension",
                "Factory",
                "FirebaseCrashlytics",
                "ArkanaKeys"
            ]
        ),
        .testTarget(
            name: "{PROJECT_NAME}Tests",
            dependencies: [
                "{PROJECT_NAME}",
                "Quick",
                "Nimble",
                "OHHTTPStubs",
                "KIF"
            ]
        )
    ]
) 
