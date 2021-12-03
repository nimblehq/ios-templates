import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.project(name: "{PROJECT_NAME}", bundleId: "{BUNDLE_ID_PRODUCTION}")

extension Project {

    static func project(name: String, bundleId: String) -> Project {
        return Project(
            name: name,
            organizationName: "Nimble",
            settings: Settings.settings(
                configurations: BuildConfiguration.allCases.map { $0.createConfiguration(projectName: name) }
            ),
            targets: [
                Target.mainTarget(name: name, bundleId: bundleId),
                Target.testsTarget(name: name, bundleId: bundleId),
                Target.uiTestsTarget(name: name, bundleId: bundleId)
            ],
            schemes: [
                Scheme.productionScheme(name: name),
                Scheme.stagingScheme(name: name)
            ]
        )
    }
}
