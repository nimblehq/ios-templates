import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.project(name: "ProjectName")

extension Project {

    static func project(name: String) -> Project {
        return Project(
            name: name,
            organizationName: "Nimble",
            targets: [
                Target.mainTarget(name: name),
                Target.testsTarget(name: name),
                Target.uiTestsTarget(name: name)
            ],
            schemes: [
                Scheme.mainScheme(name: name),
                Scheme.stagingScheme(name: name)
            ]
        )
    }
}
