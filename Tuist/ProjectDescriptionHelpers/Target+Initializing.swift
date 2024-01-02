import ProjectDescription

extension Target {

    public static func makeTargets(name: String, bundleId: String) -> [Target] {
        var targets: [Target] = []

        let frameworks = Module.allCases
            .flatMap { Target.frameworkTargets(module: $0, bundleId: bundleId) }

        targets.append(contentsOf: frameworks)

        let mainTargets: [Target] = [
            .mainTarget(name: name, bundleId: bundleId),
            .testsTarget(name: name, bundleId: bundleId),
            .kifUITestsTarget(name: name, bundleId: bundleId)
        ]

        targets.append(contentsOf: mainTargets)

        return targets
    }
}

// MARK: - Main Targets

extension Target {

    fileprivate static func mainTarget(name: String, bundleId: String) -> Target {
        return Target(
            name: name,
            platform: .iOS,
            product: .app,
            bundleId: bundleId,
            deploymentTarget: .iOS(
                targetVersion: "{TARGET_VERSION}",
                devices: [.iphone]
            ),
            infoPlist: "\(name)/\(Constant.plistsPath)/Info.plist",
            sources: ["\(name)/Sources/**"],
            resources: [
                "\(name)/Resources/**",
                "\(name)/Sources/**/.gitkeep" // To include empty folders
            ],
            scripts: [
                .sourceryScript(),
                .rswiftScript(),
                .swiftLintScript(),
                .swiftFormatLintScript(),
                .firebaseScript()
            ],
            dependencies: [
                .target(name: Module.data.name),
                .target(name: Module.domain.name)
            ]
        )
    }

    fileprivate static func testsTarget(name: String, bundleId: String) -> Target {
        let targetName = "\(name)Tests"
        return Target(
            name: targetName,
            platform: .iOS,
            product: .unitTests,
            bundleId: bundleId,
            infoPlist: "\(targetName)/\(Constant.plistsPath)/Info.plist",
            sources: ["\(targetName)/**"],
            resources: [
                "\(targetName)/**/.gitkeep", // To include empty folders
                "\(targetName)/Resources/**/*"
            ],
            scripts: [.swiftFormatScript()],
            dependencies: [.target(name: name)]
        )
    }

    fileprivate static func kifUITestsTarget(name: String, bundleId: String) -> Target {
        let targetName = "\(name)KIFUITests"
        return Target(
            name: targetName,
            platform: .iOS,
            product: .unitTests,
            bundleId: bundleId,
            infoPlist: "\(targetName)/\(Constant.plistsPath)/Info.plist",
            sources: ["\(targetName)/**"],
            resources: [
                "\(targetName)/**/.gitkeep", // To include empty folders
            ],
            dependencies: [.target(name: name)]
        )
    }
}

// MARK: - Dependencies

extension Target {

    fileprivate static func frameworkTargets(module: Module, bundleId: String) -> [Target] {
        let framework = Target(
            name: module.name,
            platform: .iOS,
            product: .framework,
            bundleId: module.getBundleId(mainBundleId: bundleId),
            deploymentTarget: .iOS(
                targetVersion: "{TARGET_VERSION}",
                devices: [.iphone]
            ),
            sources: module.sources,
            resources: module.resources,
            dependencies: module.dependencies
        )

        let testTarget = Target(
            name: "\(module.name)\(Constant.testsPath)",
            platform: .iOS,
            product: .unitTests,
            bundleId: module.getTestBundleId(mainBundleId: bundleId),
            sources: module.testsSources,
            resources: module.testsResources,
            dependencies: [.target(name: module.name)]
        )
        return [framework, testTarget]
    }
}
