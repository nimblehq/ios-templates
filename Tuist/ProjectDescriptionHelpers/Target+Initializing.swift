import ProjectDescription

extension Target {

    public static func mainTarget(name: String) -> Target {
        return Target(
            name: name,
            platform: .iOS,
            product: .app,
            bundleId: "co.nimblehq.\(name)",
            infoPlist: .extendingDefault(with: [
                "UILaunchScreen": [:]
            ]),
            sources: ["\(name)/Sources/**"],
            resources: ["\(name)/Resources/**"]
        )
    }
    
    public static func testsTarget(name: String) -> Target {
        return Target(
            name: name + "Tests",
            platform: .iOS,
            product: .unitTests,
            bundleId: "co.nimblehq.\(name)Tests",
            infoPlist: .default,
            sources: ["\(name)Tests/**"],
            dependencies: [
                .target(name: name)
            ]
        )
    }

    public static func uiTestsTarget(name: String) -> Target {
        return Target(
            name: name + "UITests",
            platform: .iOS,
            product: .uiTests,
            bundleId: "co.nimblehq.\(name)UITests",
            infoPlist: .default,
            sources: ["\(name)UITests/**"],
            dependencies: [
                .target(name: name)
            ]
        )
    }
}