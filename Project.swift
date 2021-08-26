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
                    sources: ["Sources/**"],
                    resources: ["Resources/**"]
                )
            ],
            schemes: []
        )
    }
}
