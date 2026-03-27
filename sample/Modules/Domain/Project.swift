import ProjectDescription

let project = Project(
    name: "Domain",
    settings: .settings(
        configurations: [
            .debug(name: "Debug Staging"),
            .debug(name: "Debug Production"),
            .release(name: "Release Staging"),
            .release(name: "Release Production")
        ]
    ),
    targets: [
        .target(
            name: "Domain",
            destinations: .iOS,
            product: .framework,
            bundleId: "co.nimblehq.sample.domain",
            deploymentTargets: .iOS("16.0"),
            buildableFolders: ["Sources"],
            settings: .settings(
                base: [
                    "SKIP_INSTALL": "YES",
                    "ALWAYS_SEARCH_USER_PATHS": "NO"
                ]
            )
        ),
        .target(
            name: "DomainTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "co.nimblehq.sample.domain.tests",
            deploymentTargets: .iOS("16.0"),
            buildableFolders: ["Tests"],
            dependencies: [
                .target(name: "Domain"),
                .package(product: "Quick"),
                .package(product: "Nimble")
            ]
        )
    ]
)
