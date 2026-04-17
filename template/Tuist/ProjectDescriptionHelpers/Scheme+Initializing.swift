import ProjectDescription

extension Scheme {
    public static func productionScheme(name: String) -> Scheme {
        makeScheme(
            name: name,
            debugConfiguration: .debugProduction,
            releaseConfiguration: .releaseProduction
        )
    }

    public static func stagingScheme(name: String) -> Scheme {
        makeScheme(
            name: name,
            schemeSuffix: "Staging",
            debugConfiguration: .debugStaging,
            releaseConfiguration: .releaseStaging
        )
    }

    public static func devScheme(name: String) -> Scheme {
        makeScheme(
            name: name,
            schemeSuffix: "Dev",
            debugConfiguration: .debugDev,
            releaseConfiguration: .releaseDev
        )
    }

    private static func makeScheme(
        name: String,
        schemeSuffix: String? = nil,
        debugConfiguration: BuildConfiguration,
        releaseConfiguration: BuildConfiguration
    ) -> Scheme {
        let schemeName = [name, schemeSuffix]
            .compactMap { $0 }
            .joined(separator: " ")

        return .scheme(
            name: schemeName,
            shared: true,
            buildAction: .buildAction(targets: ["\(name)"]),
            testAction: .testPlans([.path("\(name).xctestplan")], configuration: debugConfiguration.name),
            runAction: .runAction(configuration: debugConfiguration.name),
            archiveAction: .archiveAction(configuration: releaseConfiguration.name)
        )
    }
}
