import ProjectDescription

let project = Project.project(name: "ios-template")

extension Project {

    static func project(name: String) -> Project {
        return Project(
            name: name,
            organizationName: "Nimble",
            targets: [
                Target(
                    name: name,
                    platform: .iOS,
                    product: .app,
                    bundleId: "co.nimblehq.\(name)",
                    infoPlist: .extendingDefault(with: [
                        "UILaunchScreen": [:]
                    ]),
                    sources: ["ProjectName/Sources/**"],
                    resources: ["ProjectName/Resources/**"]
                ),
                Target(
                    name: name + "Tests",
                    platform: .iOS,
                    product: .unitTests,
                    bundleId: "co.nimblehq.\(name)Tests",
                    infoPlist: .default,
                    sources: ["ProjectNameTests/**"],
                    dependencies: [
                        .target(name: name)
                    ]
                ),
                Target(
                    name: name + "UITests",
                    platform: .iOS,
                    product: .uiTests,
                    bundleId: "co.nimblehq.\(name)UITests",
                    infoPlist: .default,
                    sources: ["ProjectNameUITests/**"],
                    dependencies: [
                        .target(name: name)
                    ]
                )
            ],
            schemes: []
        )
    }
}
