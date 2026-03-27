import ProjectDescription

let project = Project(
    name: "Auth",
    settings: .settings(
        configurations: [
            .debug(name: "Debug Staging"),
            .debug(name: "Debug Production"),
            .release(name: "Release Staging"),
            .release(name: "Release Production")
        ]
    ),
    targets: [
        // 1. Implementation — local storage, no Domain needed.
        .target(
            name: "Auth",
            destinations: .iOS,
            product: .framework,
            bundleId: "co.nimblehq.sample.auth",
            deploymentTargets: .iOS("16.0"),
            buildableFolders: ["Sources"],
            settings: .settings(base: ["SKIP_INSTALL": "YES", "ALWAYS_SEARCH_USER_PATHS": "NO"])
        ),

        // 2. Tests — unit tests; mocks live alongside specs in Tests/.
        .target(
            name: "AuthTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "co.nimblehq.sample.auth.tests",
            deploymentTargets: .iOS("16.0"),
            buildableFolders: ["Tests"],
            dependencies: [
                .target(name: "Auth"),
                .package(product: "Quick"),
                .package(product: "Nimble")
            ]
        ),

        // 3. Example — standalone sandbox app for isolated auth development.
        .target(
            name: "AuthExample",
            destinations: .iOS,
            product: .app,
            bundleId: "co.nimblehq.sample.auth.example",
            deploymentTargets: .iOS("16.0"),
            infoPlist: .extendingDefault(with: [
                "CFBundleName": "Auth Example",
                "UILaunchStoryboardName": ""
            ]),
            buildableFolders: ["Example"],
            dependencies: [
                .target(name: "Auth")
            ]
        )
    ],
    schemes: [
        .scheme(
            name: "AuthExample",
            shared: true,
            buildAction: .buildAction(targets: ["AuthExample"]),
            testAction: .targets(["AuthTests"], configuration: "Debug Staging"),
            runAction: .runAction(configuration: "Debug Staging"),
            archiveAction: .archiveAction(configuration: "Release Staging")
        )
    ]
)
