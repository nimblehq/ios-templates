import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.project(name: "ProjectName")

extension Project {

    static func project(name: String) -> Project {
        return Project(
            name: name,
            organizationName: "Nimble",
            settings: Settings(
                configurations: [
                    .debug(name: "Debug", xcconfig: "\(name)/Configurations/XCConfigs/Debug.xcconfig"),
                    .release(name: "Release", xcconfig: "\(name)/Configurations/XCConfigs/Release.xcconfig"),
                ]
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
