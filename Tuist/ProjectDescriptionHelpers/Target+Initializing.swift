import ProjectDescription

extension Target {

    public static func mainTarget(name: String, bundleId: String = "co.nimblehq") -> Target {
        return Target(
            name: name,
            platform: .iOS,
            product: .app,
            bundleId: "\(bundleId).\(name)",
            infoPlist: "\(name)/Configurations/Plists/\(name).plist",
            sources: ["\(name)/Sources/**"],
            resources: ["\(name)/Resources/**"]
        )
    }
    
    public static func testsTarget(name: String, bundleId: String = "co.nimblehq") -> Target {
        return Target(
            name: "\(name)Tests",
            platform: .iOS,
            product: .unitTests,
            bundleId: "\(bundleId).\(name)Tests",
            infoPlist: .default,
            sources: ["\(name)Tests/**"],
            dependencies: [
                .target(name: name)
            ]
        )
    }

    public static func uiTestsTarget(name: String, bundleId: String = "co.nimblehq") -> Target {
        return Target(
            name: "\(name)UITests",
            platform: .iOS,
            product: .uiTests,
            bundleId: "\(bundleId).\(name)UITests",
            infoPlist: .default,
            sources: ["\(name)UITests/**"],
            dependencies: [
                .target(name: name)
            ]
        )
    }
}
