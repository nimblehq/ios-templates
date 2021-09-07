import ProjectDescription

extension Target {

    private static let plistsPath: String = "Configurations/Plists"

    public static func mainTarget(name: String, bundleId: String = "co.nimblehq") -> Target {
        return Target(
            name: name,
            platform: .iOS,
            product: .app,
            bundleId: "\(bundleId).\(name)",
            infoPlist: "\(name)/\(plistsPath)/Info.plist",
            sources: ["\(name)/Sources/**"],
            resources: [
                "\(name)/Resources/**",
                "\(name)/Sources/**/.gitkeep" // To include empty folders
            ],
            actions: [
                TargetAction.sourceryAction(),
                TargetAction.rswiftAction(),
                TargetAction.swiftLintAction()
            ]
        )
    }
    
    public static func testsTarget(name: String, bundleId: String = "co.nimblehq") -> Target {
        let targetName = "\(name)Tests"
        return Target(
            name: targetName,
            platform: .iOS,
            product: .unitTests,
            bundleId: "\(bundleId).\(targetName)",
            infoPlist: "\(targetName)/\(plistsPath)/Info.plist",
            sources: ["\(targetName)**"],
            resources: ["\(targetName)/**/.gitkeep"], // To include empty folders
            dependencies: [
                .target(name: name)
            ]
        )
    }

    public static func uiTestsTarget(name: String, bundleId: String = "co.nimblehq") -> Target {
        let targetName = "\(name)UITests"
        return Target(
            name: "\(targetName)",
            platform: .iOS,
            product: .uiTests,
            bundleId: "\(bundleId).\(targetName)",
            infoPlist: "\(targetName)/\(plistsPath)/Info.plist",
            sources: ["\(targetName)/**"],
            resources: ["\(targetName)/**/.gitkeep"], // To include empty folders
            dependencies: [
                .target(name: name)
            ]
        )
    }
}
