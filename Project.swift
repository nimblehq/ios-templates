import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.project(name: "{PROJECT_NAME}", bundleId: "${PRODUCT_BUNDLE_IDENTIFIER}")

extension Project {
    static func project(name: String, bundleId: String) -> Project {
        return Project(
            name: name,
            organizationName: "Nimble",
            options: .options(
                disableBundleAccessors: true,
                disableSynthesizedResourceAccessors: true
            ),
            packages: [
                // Backend
                .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.9.0"),
                .package(url: "https://github.com/nimblehq/JSONMapper.git", from: "1.1.1"), // Using from: as Tuist doesn't support exact: with URL
                // UI
                .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.11.0"),
                // Storage
                .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "4.2.2"),
                // Tools
                .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "11.0.0"),
                .package(url: "https://github.com/nimblehq/NimbleExtension.git", .branch("master")),
                .package(url: "https://github.com/hmlongco/Factory.git", from: "2.3.0"),
                // Testing
                .package(url: "https://github.com/Quick/Quick.git", from: "7.4.0"),
                .package(url: "https://github.com/Quick/Nimble.git", from: "13.0.0"),
                .package(url: "https://github.com/AliSoftware/OHHTTPStubs.git", from: "9.1.0"),
            ],
            settings: .settings(
                configurations: BuildConfiguration.allCases.map { $0.createConfiguration(projectName: name) },
                defaultSettings: .none
            ),
            targets: Target.makeTargets(name: name, bundleId: bundleId),
            schemes: [
                .productionScheme(name: name),
                .stagingScheme(name: name)
            ]
        )
    }
}
