import ProjectDescription

extension Target {

    private static let plistsPath: String = "Configurations/Plists"

    public static func mainTarget(name: String, bundleId: String) -> Target {
        return Target(
            name: name,
            platform: .iOS,
            product: .app,
            bundleId: bundleId,
            infoPlist: "\(name)/\(plistsPath)/Info.plist",
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
            ]
        )
    }

    public static func testsTarget(name: String, bundleId: String) -> Target {
        let targetName = "\(name)Tests"
        return Target(
            name: targetName,
            platform: .iOS,
            product: .unitTests,
            bundleId: bundleId,
            infoPlist: "\(targetName)/\(plistsPath)/Info.plist",
            sources: ["\(targetName)/**"],
            resources: [
                "\(targetName)/**/.gitkeep", // To include empty folders
                "\(targetName)/Resources/**/*"
            ],
            scripts: [.swiftFormatScript()],
            dependencies: [.target(name: name)]
        )
    }

    public static func uiTestsTarget(name: String, bundleId: String) -> Target {
        let targetName = "\(name)UITests"
        return Target(
            name: targetName,
            platform: .iOS,
            product: .uiTests,
            bundleId: bundleId,
            infoPlist: "\(targetName)/\(plistsPath)/Info.plist",
            sources: ["\(targetName)/**"],
            resources: [
                "\(targetName)/**/.gitkeep", // To include empty folders
                "\(targetName)/Resources/**/*"
            ], 
            dependencies: [.target(name: name)]
        )
    }
}
