import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.project(name: "{PROJECT_NAME}")

extension Project {

    static func project(name: String) -> Project {
        return Project(
            name: name,
            organizationName: "Nimble",
            settings: Settings(
                configurations: ProjectBuildConfiguration.allCases
                    .map { $0.createConfiguration(projectName: name) }
            ),
            targets: [
                Target.mainTarget(name: name),
                Target.testsTarget(name: name),
                Target.uiTestsTarget(name: name)
            ],
            schemes: [
                Scheme.productionScheme(name: name),
                Scheme.stagingScheme(name: name)
            ]
        )
    }
}
