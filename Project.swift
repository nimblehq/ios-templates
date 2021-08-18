import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.project(name: "ios-template")

extension Project {

    static func project(name: String) -> Project {
        return Project(
            name: name,
            organizationName: "Nimble",
            targets: [
                // Need to update "ProjectName" to `name` when implement script
                Target.mainTarget(name: "ProjectName"),
                Target.testsTarget(name: "ProjectName"),
                Target.uiTestsTarget(name: "ProjectName")
            ],
            schemes: []
        )
    }
}
