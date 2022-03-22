import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.project(name: "{PROJECT_NAME}", bundleId: "{BUNDLE_ID_PRODUCTION}", compileTimeWarning: {COMPILE_TIME_WARNING})

extension Project {

    static func project(name: String, bundleId: String, compileTimeWarning: Int?) -> Project {
        return Project(
            name: name,
            organizationName: "Nimble",
            settings: .settings(
                configurations: BuildConfiguration.allCases.map { $0.createConfiguration(projectName: name, compileTimeWarning: compileTimeWarning) }
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
