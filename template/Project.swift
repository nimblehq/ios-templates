import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.project(name: "{PROJECT_NAME}", bundleId: "${PRODUCT_BUNDLE_IDENTIFIER}")

extension Project {
    static func project(name: String, bundleId: String) -> Project {
        return Project(
            name: name,
            organizationName: "Nimble",
            options: .options(
                disableBundleAccessors: true,
                disableSynthesizedResourceAccessors: true
            ),
            // Note: Package dependencies are defined in TWO places for different purposes:
            //
            // 1. Root Package.swift (with #if TUIST block):
            //    - Tuist reads this file to resolve and cache Swift Package Manager dependencies
            //    - Acts as the "source of truth" for dependency versions and URLs
            //    - Tuist uses PackageSettings from this file to configure how packages are integrated
            //    - This file is NOT used by iOSTemplateMaker (the template tool has its own Package.swift)
            //
            // 2. Project.swift packages array (this file):
            //    - Tells Tuist which packages to actually include in the generated Xcode project
            //    - References packages defined in the root Package.swift
            //    - These packages appear in Xcode's "Package Dependencies" section
            //
            // Why both?
            // - Package.swift: Dependency resolution and caching (Tuist's internal mechanism)
            // - Project.swift packages: Which packages to link into targets (what developers see in Xcode)
            //
            // They MUST be kept in sync - if a package is in Project.swift but not Package.swift,
            // Tuist won't be able to resolve it. If it's in Package.swift but not Project.swift,
            // it won't be included in the generated project.
            packages: [
                // Backend
                .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.11.1"),
                .package(url: "https://github.com/nimblehq/JSONMapper.git", from: "1.1.1"), // Using from: as Tuist doesn't support exact: with URL
                // UI
                .package(url: "https://github.com/onevcat/Kingfisher.git", from: "8.8.0"),
                // Storage
                .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "4.2.2"),
                // Tools
                .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "12.11.0"),
                .package(url: "https://github.com/nimblehq/NimbleExtension.git", .branch("master")),
                .package(url: "https://github.com/hmlongco/Factory.git", from: "2.5.3"),
                // Testing
                .package(url: "https://github.com/Quick/Quick.git", from: "7.6.2"),
                .package(url: "https://github.com/Quick/Nimble.git", from: "14.0.0"),
                .package(url: "https://github.com/AliSoftware/OHHTTPStubs.git", from: "9.1.0"),
            ],
            settings: .settings(
                base: ["MARKETING_VERSION": "\(Constant.manualVersion)"],
                configurations: BuildConfiguration.allCases.map { $0.createConfiguration(projectName: name) },
                defaultSettings: .none
            ),
            targets: Target.makeTargets(name: name, bundleId: bundleId),
            schemes: [
                .productionScheme(name: name),
                .stagingScheme(name: name),
                .devScheme(name: name)
            ]
        )
    }
}
