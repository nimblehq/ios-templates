import ProjectDescription

extension Scheme {

    public static func productionScheme(name: String) -> Scheme {
        let debugConfigName = ProjectBuildConfiguration.debugProduction.name
        let releaseConfigName = ProjectBuildConfiguration.releaseProduction.name
        return Scheme(
            name: name,
            shared: true,
            buildAction: BuildAction(targets: ["\(name)"]),
            testAction: TestAction(
                targets: ["\(name)Tests", "\(name)UITests"],
                configurationName: debugConfigName
            ),
            runAction: RunAction(configurationName: debugConfigName),
            archiveAction: ArchiveAction(configurationName: releaseConfigName),
            profileAction: ProfileAction(configurationName: debugConfigName),
            analyzeAction: AnalyzeAction(configurationName: debugConfigName)
        )
    }

    public static func stagingScheme(name: String) -> Scheme {
        let debugConfigName = ProjectBuildConfiguration.debugStaging.name
        let releaseConfigName = ProjectBuildConfiguration.releaseStaging.name
        return Scheme(
            name: "\(name) Staging",
            shared: true,
            buildAction: BuildAction(targets: ["\(name)"]),
            testAction: TestAction(
                targets: ["\(name)Tests", "\(name)UITests"],
                configurationName: debugConfigName
            ),
            runAction: RunAction(configurationName: debugConfigName),
            archiveAction: ArchiveAction(configurationName: releaseConfigName),
            profileAction: ProfileAction(configurationName: debugConfigName),
            analyzeAction: AnalyzeAction(configurationName: debugConfigName)
        )
    }
}
