import ProjectDescription

let project = Project(
    name: "Home",
    settings: .settings(
        configurations: [
            .debug(name: "Debug Staging"),
            .debug(name: "Debug Production"),
            .release(name: "Release Staging"),
            .release(name: "Release Production")
        ]
    ),
    targets: [
        // 1. Implementation — depends on Domain.
        .target(
            name: "Home",
            destinations: .iOS,
            product: .framework,
            bundleId: "co.nimblehq.sample.home",
            deploymentTargets: .iOS("16.0"),
            sources: ["Sources/**"],
            dependencies: [
                .project(target: "Domain", path: "../Domain")
            ],
            settings: .settings(base: ["SKIP_INSTALL": "YES", "ALWAYS_SEARCH_USER_PATHS": "NO"])
        ),

        // 2. Testing — mocks and stubs; depends on Home.
        .target(
            name: "HomeTesting",
            destinations: .iOS,
            product: .framework,
            bundleId: "co.nimblehq.sample.home.testing",
            deploymentTargets: .iOS("16.0"),
            sources: ["Testing/**"],
            dependencies: [
                .target(name: "Home")
            ],
            settings: .settings(base: ["SKIP_INSTALL": "YES", "ALWAYS_SEARCH_USER_PATHS": "NO"])
        ),

        // 3. Tests — unit tests; depends on implementation + testing helpers.
        .target(
            name: "HomeTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "co.nimblehq.sample.home.tests",
            deploymentTargets: .iOS("16.0"),
            sources: ["Tests/**"],
            dependencies: [
                .target(name: "Home"),
                .target(name: "HomeTesting"),
                .package(product: "Quick"),
                .package(product: "Nimble")
            ]
        ),

        // 4. Example — standalone sandbox app for isolated feature development.
        .target(
            name: "HomeExample",
            destinations: .iOS,
            product: .app,
            bundleId: "co.nimblehq.sample.home.example",
            deploymentTargets: .iOS("16.0"),
            infoPlist: .extendingDefault(with: [
                "CFBundleName": "Home Example",
                "UILaunchStoryboardName": ""
            ]),
            sources: ["Example/**"],
            dependencies: [
                .target(name: "Home"),
                .target(name: "HomeTesting")
            ]
        )
    ],
    schemes: [
        .scheme(
            name: "HomeExample",
            shared: true,
            buildAction: .buildAction(targets: ["HomeExample"]),
            testAction: .targets(["HomeTests"], configuration: "Debug Staging"),
            runAction: .runAction(configuration: "Debug Staging"),
            archiveAction: .archiveAction(configuration: "Release Staging")
        )
    ]
)
