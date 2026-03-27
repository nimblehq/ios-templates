import ProjectDescription

// Usage:
//   mise exec -- tuist scaffold module --name Payment --bundle-id-suffix payment
//
// name            — PascalCase module name, used for types and file names (e.g. "Payment")
// bundle-id-suffix — lowercase suffix for bundle IDs (e.g. "payment")

let nameAttribute: Template.Attribute = .required("name")
let bundleIdSuffixAttribute: Template.Attribute = .required("bundle-id-suffix")

let template = Template(
    description: "Scaffolds a new feature module under Modules/ matching the project's TMA structure.",
    attributes: [nameAttribute, bundleIdSuffixAttribute],
    items: [

        // MARK: - Project.swift

        .string(
            path: "Modules/\(nameAttribute)/Project.swift",
            contents: """
            import ProjectDescription

            let project = Project(
                name: "\(nameAttribute)",
                settings: .settings(
                    configurations: [
                        .debug(name: "Debug Staging"),
                        .debug(name: "Debug Production"),
                        .release(name: "Release Staging"),
                        .release(name: "Release Production")
                    ]
                ),
                targets: [
                    // 1. Implementation
                    .target(
                        name: "\(nameAttribute)",
                        destinations: .iOS,
                        product: .framework,
                        bundleId: "co.nimblehq.sample.\(bundleIdSuffixAttribute)",
                        deploymentTargets: .iOS("16.0"),
                        buildableFolders: ["Sources"],
                        dependencies: [
                            .project(target: "Domain", path: "../Domain")
                        ],
                        settings: .settings(base: ["SKIP_INSTALL": "YES", "ALWAYS_SEARCH_USER_PATHS": "NO"])
                    ),

                    // 2. Tests
                    .target(
                        name: "\(nameAttribute)Tests",
                        destinations: .iOS,
                        product: .unitTests,
                        bundleId: "co.nimblehq.sample.\(bundleIdSuffixAttribute).tests",
                        deploymentTargets: .iOS("16.0"),
                        buildableFolders: ["Tests"],
                        dependencies: [
                            .target(name: "\(nameAttribute)"),
                            .package(product: "Quick"),
                            .package(product: "Nimble")
                        ]
                    ),

                    // 3. Example
                    .target(
                        name: "\(nameAttribute)Example",
                        destinations: .iOS,
                        product: .app,
                        bundleId: "co.nimblehq.sample.\(bundleIdSuffixAttribute).example",
                        deploymentTargets: .iOS("16.0"),
                        infoPlist: .extendingDefault(with: [
                            "CFBundleName": "\(nameAttribute) Example",
                            "UILaunchStoryboardName": ""
                        ]),
                        buildableFolders: ["Example"],
                        dependencies: [
                            .target(name: "\(nameAttribute)")
                        ]
                    )
                ],
                schemes: [
                    .scheme(
                        name: "\(nameAttribute)Example",
                        shared: true,
                        buildAction: .buildAction(targets: ["\(nameAttribute)Example"]),
                        testAction: .targets(["\(nameAttribute)Tests"], configuration: "Debug Staging"),
                        runAction: .runAction(configuration: "Debug Staging"),
                        archiveAction: .archiveAction(configuration: "Release Staging")
                    )
                ]
            )
            """
        ),

        // MARK: - Sources

        .string(
            path: "Modules/\(nameAttribute)/Sources/Helpers/.gitkeep",
            contents: ""
        ),
        .string(
            path: "Modules/\(nameAttribute)/Sources/Models/.gitkeep",
            contents: ""
        ),
        .string(
            path: "Modules/\(nameAttribute)/Sources/Presentations/Modules/\(nameAttribute)/\(nameAttribute)Screen.swift",
            contents: """
            import SwiftUI

            public struct \(nameAttribute)Screen: View {

                public init() {}

                public var body: some View {
                    Text("\(nameAttribute)")
                }
            }

            #Preview {
                \(nameAttribute)Screen()
            }
            """
        ),
        .string(
            path: "Modules/\(nameAttribute)/Sources/Presentations/Modules/\(nameAttribute)/\(nameAttribute)ViewModel.swift",
            contents: """
            import Combine
            import Foundation

            @MainActor
            final class \(nameAttribute)ViewModel: ObservableObject {

            }
            """
        ),

        // MARK: - Tests

        .string(
            path: "Modules/\(nameAttribute)/Tests/\(nameAttribute)Tests/Dummy/.gitkeep",
            contents: ""
        ),
        .string(
            path: "Modules/\(nameAttribute)/Tests/\(nameAttribute)Tests/Mocks/Managers/.gitkeep",
            contents: ""
        ),
        .string(
            path: "Modules/\(nameAttribute)/Tests/\(nameAttribute)Tests/Mocks/Repositories/.gitkeep",
            contents: ""
        ),
        .string(
            path: "Modules/\(nameAttribute)/Tests/\(nameAttribute)Tests/Mocks/UseCases/.gitkeep",
            contents: ""
        ),
        .string(
            path: "Modules/\(nameAttribute)/Tests/\(nameAttribute)Tests/Specs/\(nameAttribute)ScreenSpec.swift",
            contents: """
            import Nimble
            import Quick
            @testable import \(nameAttribute)

            final class \(nameAttribute)ScreenSpec: QuickSpec {

                override class func spec() {
                    describe("\(nameAttribute)Screen") {
                        it("can be instantiated") {
                            let screen = \(nameAttribute)Screen()
                            expect(screen).toNot(beNil())
                        }
                    }
                }
            }
            """
        ),
        .string(
            path: "Modules/\(nameAttribute)/Tests/\(nameAttribute)Tests/Supports/Extension/.gitkeep",
            contents: ""
        ),

        // MARK: - Example

        .string(
            path: "Modules/\(nameAttribute)/Example/\(nameAttribute)ExampleApp.swift",
            contents: """
            import \(nameAttribute)
            import SwiftUI

            @main
            struct \(nameAttribute)ExampleApp: App {

                var body: some Scene {
                    WindowGroup {
                        \(nameAttribute)Screen()
                    }
                }
            }
            """
        )
    ]
)
