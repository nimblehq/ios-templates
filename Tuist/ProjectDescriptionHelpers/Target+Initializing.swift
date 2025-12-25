import ProjectDescription

extension Target {
    public static func makeTargets(name: String, bundleId: String) -> [Target] {
        var targets: [Target] = []

        // Framework modules (Data, Domain) + their unit tests
        let moduleTargets = Module.allCases.flatMap { frameworkTargets(module: $0, bundleId: bundleId) }
        targets.append(contentsOf: moduleTargets)

        // App + app tests
        targets.append(contentsOf: [
            .mainTarget(name: name, bundleId: bundleId),
            .testsTarget(name: name, bundleId: bundleId)
        ])

        return targets
    }
}

extension Target {
    fileprivate static func mainTarget(name: String, bundleId: String) -> Target {
        return .target(
            name: name,
            destinations: .iOS,
            product: .app,
            bundleId: bundleId,
            deploymentTargets: .iOS("{TARGET_VERSION}"),
            infoPlist: "\(name)/Configurations/Plists/Info.plist",
            sources: ["\(name)/Sources/**"],
            resources: ["\(name)/Resources/**"],
            dependencies: [
                // Internal modules
                .target(name: Module.data.name),
                .target(name: Module.domain.name),
                // Backend
                .package(product: "Alamofire"),
                .package(product: "JSONAPIMapper"),
                // UI
                .package(product: "Kingfisher"),
                // Storage
                .package(product: "KeychainAccess"),
                // Tools
                .package(product: "FirebaseCrashlytics"), // From firebase-ios-sdk
                .package(product: "NimbleExtension"),
                .package(product: "Factory"),
                // Note: R.swift is a code generation tool, not a library dependency
                // It will be added later as a build script when we add scripts incrementally
            ],
            settings: .settings(
                base: [
                    "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
                    "ALWAYS_SEARCH_USER_PATHS": "NO"
                ]
            )
        )
    }

    fileprivate static func frameworkTargets(module: Module, bundleId: String) -> [Target] {
        let framework = Target.target(
            name: module.name,
            destinations: .iOS,
            product: .framework,
            bundleId: module.bundleId(mainBundleId: bundleId),
            deploymentTargets: .iOS("{TARGET_VERSION}"),
            sources: module.sources,
            resources: module.resources,
            dependencies: module.dependencies,
            settings: .settings(
                base: [
                    "SKIP_INSTALL": "YES",
                    "ALWAYS_SEARCH_USER_PATHS": "NO"
                ]
            )
        )

        let testTarget = Target.target(
            name: "\(module.name)\(Constant.testsPath)",
            destinations: .iOS,
            product: .unitTests,
            bundleId: module.testBundleId(mainBundleId: bundleId),
            sources: module.testsSources,
            resources: module.testsResources,
            dependencies: [
                .target(name: module.name)
            ]
        )

        return [framework, testTarget]
    }

    fileprivate static func testsTarget(name: String, bundleId: String) -> Target {
        let targetName = "\(name)Tests"
        return .target(
            name: targetName,
            destinations: .iOS,
            product: .unitTests,
            bundleId: bundleId,
            infoPlist: "\(targetName)/Configurations/Plists/Info.plist",
            sources: ["\(targetName)/**"],
            dependencies: [
                .target(name: name),
                // Testing
                .package(product: "Quick"),
                .package(product: "Nimble"),
                .package(product: "OHHTTPStubsSwift"), // From OHHTTPStubs package
            ]
        )
    }
}
