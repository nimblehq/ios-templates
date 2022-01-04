import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.project(name: "{PROJECT_NAME}", bundleId: "{BUNDLE_ID_PRODUCTION}")

extension Project {

    static func project(name: String, bundleId: String) -> Project {
        return Project(
            name: name,
            organizationName: "Nimble",
            settings: .settings(
                configurations: BuildConfiguration.allCases.map { $0.createConfiguration(projectName: name) }
            ),
            targets: [
                .mainTarget(name: name, bundleId: bundleId),
                .testsTarget(name: name, bundleId: bundleId),
                .uiTestsTarget(name: name, bundleId: bundleId)
            ],
            schemes: [
                .productionScheme(name: name),
                .stagingScheme(name: name)
            ]
        )
    }
}
