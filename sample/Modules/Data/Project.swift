import ProjectDescription

let project = Project(
    name: "Data",
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
            name: "Data",
            destinations: .iOS,
            product: .framework,
            bundleId: "co.nimblehq.sample.data",
            deploymentTargets: .iOS("16.0"),
            buildableFolders: ["Sources"],
            dependencies: [
                .project(target: "Domain", path: "../Domain"),
                .package(product: "Alamofire")
            ],
            settings: .settings(
                base: [
                    "SKIP_INSTALL": "YES",
                    "ALWAYS_SEARCH_USER_PATHS": "NO"
                ]
            )
        ),
        .target(
            name: "DataTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "co.nimblehq.sample.data.tests",
            deploymentTargets: .iOS("16.0"),
            buildableFolders: ["Tests"],
            dependencies: [
                .target(name: "Data"),
                .package(product: "Quick"),
                .package(product: "Nimble"),
                .package(product: "OHHTTPStubsSwift")
            ]
        )
    ]
)
