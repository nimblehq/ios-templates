import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.project(name: "{PROJECT_NAME}", bundleId: "${PRODUCT_BUNDLE_IDENTIFIER}")

extension Project {

    static func project(name: String, bundleId: String) -> Project {
        let targets = Target.makeTargets(name: name, bundleId: bundleId)

        return Project(
            name: name,
            organizationName: "Nimble",
            options: .options(
                disableBundleAccessors: true,
                disableSynthesizedResourceAccessors: true
            ),
            settings: .settings(
                configurations: BuildConfiguration.allCases.map { $0.createConfiguration(projectName: name) }
            ),
            targets: targets,
            schemes: [
                .productionScheme(name: name),
                .stagingScheme(name: name),
                .kifUITestsScheme(name: name)
            ]
        )
    }
}
