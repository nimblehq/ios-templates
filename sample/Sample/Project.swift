import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "Sample",
    organizationName: "Nimble",
    options: .options(
        disableBundleAccessors: true,
        disableSynthesizedResourceAccessors: true
    ),
    packages: [
        // Backend
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.10.0"),
        .package(url: "https://github.com/nimblehq/JSONMapper.git", from: "1.1.1"),
        // UI
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.12.0"),
        // Storage
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "4.2.2"),
        // Tools
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "11.15.0"),
        .package(url: "https://github.com/nimblehq/NimbleExtension.git", .branch("master")),
        .package(url: "https://github.com/hmlongco/Factory.git", from: "2.5.0"),
        // Testing
        .package(url: "https://github.com/Quick/Quick.git", from: "7.6.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "13.8.0"),
        .package(url: "https://github.com/AliSoftware/OHHTTPStubs.git", from: "9.1.0"),
    ],
    settings: .settings(
        configurations: BuildConfiguration.allCases.map { $0.createConfiguration() },
        defaultSettings: .none
    ),
    targets: [
        .target(
            name: "Sample",
            destinations: .iOS,
            product: .app,
            bundleId: "${PRODUCT_BUNDLE_IDENTIFIER}",
            deploymentTargets: .iOS("16.0"),
            infoPlist: "Configurations/Plists/Info.plist",
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                // Modules
                .project(target: "Data", path: "../Modules/Data"),
                .project(target: "Domain", path: "../Modules/Domain"),
                // TMA features
                .project(target: "Home", path: "../Modules/Home"),
                .project(target: "HomeInterface", path: "../Modules/Home"),
                .project(target: "Auth", path: "../Modules/Auth"),
                .project(target: "AuthInterface", path: "../Modules/Auth"),
                // Backend
                .package(product: "Alamofire"),
                .package(product: "JSONAPIMapper"),
                // UI
                .package(product: "Kingfisher"),
                // Storage
                .package(product: "KeychainAccess"),
                // Tools
                .package(product: "FirebaseCrashlytics"),
                .package(product: "NimbleExtension"),
                .package(product: "FactoryKit"),
            ],
            settings: .settings(
                base: [
                    "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
                    "ALWAYS_SEARCH_USER_PATHS": "NO"
                ]
            )
        ),
        .target(
            name: "SampleTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "${PRODUCT_BUNDLE_IDENTIFIER}",
            deploymentTargets: .iOS("16.0"),
            infoPlist: "../SampleTests/Configurations/Plists/Info.plist",
            sources: ["../SampleTests/**"],
            dependencies: [
                .target(name: "Sample"),
                .package(product: "Quick"),
                .package(product: "Nimble"),
                .package(product: "OHHTTPStubsSwift")
            ]
        ),
        .target(
            name: "SampleKIFUITests",
            destinations: .iOS,
            product: .uiTests,
            bundleId: "${PRODUCT_BUNDLE_IDENTIFIER}",
            deploymentTargets: .iOS("16.0"),
            infoPlist: "../SampleKIFUITests/Configurations/Plists/Info.plist",
            sources: ["../SampleKIFUITests/**"]
        )
    ],
    schemes: [
        .productionScheme(name: "Sample"),
        .stagingScheme(name: "Sample")
    ]
)
