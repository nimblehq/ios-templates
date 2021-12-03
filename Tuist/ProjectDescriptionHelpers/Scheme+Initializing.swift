import ProjectDescription

extension Scheme {

    public static func productionScheme(name: String) -> Scheme {
        let debugConfigName = BuildConfiguration.debugProduction.name
        let releaseConfigName = BuildConfiguration.releaseProduction.name
        return Scheme(
            name: name,
            shared: true,
            buildAction: BuildAction(targets: ["\(name)"]),
            testAction: TestAction.targets(
                ["\(name)Tests", "\(name)UITests"],
                configuration: debugConfigName
            ),
            runAction: RunAction.runAction(configuration: debugConfigName),
            archiveAction: ArchiveAction.archiveAction(configuration: releaseConfigName),
            profileAction: ProfileAction.profileAction(configuration: debugConfigName),
            analyzeAction: AnalyzeAction.analyzeAction(configuration: debugConfigName)
        )
    }

    public static func stagingScheme(name: String) -> Scheme {
        let debugConfigName = BuildConfiguration.debugStaging.name
        let releaseConfigName = BuildConfiguration.releaseStaging.name
        return Scheme(
            name: "\(name) Staging",
            shared: true,
            buildAction: BuildAction(targets: ["\(name)"]),
            testAction: TestAction.targets(
                ["\(name)Tests", "\(name)UITests"],
                configuration: debugConfigName
            ),
            runAction: RunAction.runAction(configuration: debugConfigName),
            archiveAction: ArchiveAction.archiveAction(configuration: releaseConfigName),
            profileAction: ProfileAction.profileAction(configuration: debugConfigName),
            analyzeAction: AnalyzeAction.analyzeAction(configuration: debugConfigName)
        )
    }
}
