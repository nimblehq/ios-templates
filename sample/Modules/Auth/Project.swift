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
        // 1. Interface — public protocols and types; no dependencies.
        .target(
            name: "AuthInterface",
            destinations: .iOS,
            product: .framework,
            bundleId: "co.nimblehq.sample.auth.interface",
            deploymentTargets: .iOS("16.0"),
            sources: ["Interface/**"],
            settings: .settings(base: ["SKIP_INSTALL": "YES", "ALWAYS_SEARCH_USER_PATHS": "NO"])
        ),

        // 2. Implementation — depends on Interface only (local storage, no Domain needed).
        .target(
            name: "Auth",
            destinations: .iOS,
            product: .framework,
            bundleId: "co.nimblehq.sample.auth",
            deploymentTargets: .iOS("16.0"),
            sources: ["Sources/**"],
            dependencies: [
                .target(name: "AuthInterface")
            ],
            settings: .settings(base: ["SKIP_INSTALL": "YES", "ALWAYS_SEARCH_USER_PATHS": "NO"])
        ),

        // 3. Testing — mocks and stubs; depends only on Interface.
        .target(
            name: "AuthTesting",
            destinations: .iOS,
            product: .framework,
            bundleId: "co.nimblehq.sample.auth.testing",
            deploymentTargets: .iOS("16.0"),
            sources: ["Testing/**"],
            dependencies: [
                .target(name: "AuthInterface")
            ],
            settings: .settings(base: ["SKIP_INSTALL": "YES", "ALWAYS_SEARCH_USER_PATHS": "NO"])
        ),

        // 4. Tests — unit tests using mocks from Testing target.
        .target(
            name: "AuthTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "co.nimblehq.sample.auth.tests",
            deploymentTargets: .iOS("16.0"),
            sources: ["Tests/**"],
            dependencies: [
                .target(name: "Auth"),
                .target(name: "AuthTesting"),
                .package(product: "Quick"),
                .package(product: "Nimble")
            ]
        ),

        // 5. Example — standalone sandbox app for isolated auth development.
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
            sources: ["Example/**"],
            dependencies: [
                .target(name: "Auth"),
                .target(name: "AuthTesting")
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
