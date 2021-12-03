import ProjectDescription

extension Scheme {

    public static func productionScheme(name: String) -> Scheme {
        let debugConfigName = BuildConfiguration.debugProduction.name
        let releaseConfigName = BuildConfiguration.releaseProduction.name
        return Scheme(
            name: name,
            shared: true,
            buildAction: .buildAction(targets: ["\(name)"]),
            testAction: .targets(["\(name)Tests", "\(name)UITests"], configuration: debugConfigName),
            runAction: .runAction(configuration: debugConfigName),
            archiveAction: .archiveAction(configuration: releaseConfigName),
            profileAction: .profileAction(configuration: debugConfigName),
            analyzeAction: .analyzeAction(configuration: debugConfigName)
        )
    }

    public static func stagingScheme(name: String) -> Scheme {
        let debugConfigName = BuildConfiguration.debugStaging.name
        let releaseConfigName = BuildConfiguration.releaseStaging.name
        return Scheme(
            name: "\(name) Staging",
            shared: true,
            buildAction: .buildAction(targets: ["\(name)"]),
            testAction: .targets(["\(name)Tests", "\(name)UITests"], configuration: debugConfigName),
            runAction: .runAction(configuration: debugConfigName),
            archiveAction: .archiveAction(configuration: releaseConfigName),
            profileAction: .profileAction(configuration: debugConfigName),
            analyzeAction: .analyzeAction(configuration: debugConfigName)
        )
    }
}
