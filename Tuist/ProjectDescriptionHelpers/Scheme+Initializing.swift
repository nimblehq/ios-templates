import ProjectDescription

extension Scheme {

    public static func productionScheme(name: String) -> Scheme {
        #warning("We should use Debug Production and Release Production instead after implement build configurations")
        return Scheme(
            name: name,
            shared: true,
            buildAction: BuildAction(targets: ["\(name)"]),
            testAction: TestAction(
                targets: ["\(name)Tests", "\(name)UITests"],
                configurationName: ProjectBuildConfiguration.debugProduction.name
            ),
            runAction: RunAction(configurationName: ProjectBuildConfiguration.debugProduction.name),
            archiveAction: ArchiveAction(configurationName: ProjectBuildConfiguration.releaseProduction.name),
            profileAction: ProfileAction(configurationName: ProjectBuildConfiguration.debugProduction.name),
            analyzeAction: AnalyzeAction(configurationName: ProjectBuildConfiguration.debugProduction.name)
        )
    }

    public static func stagingScheme(name: String) -> Scheme {
        #warning("We should use Debug Staging and Release Staging instead after implement build configurations")
        return Scheme(
            name: "\(name) Staging",
            shared: true,
            buildAction: BuildAction(targets: ["\(name)"]),
            testAction: TestAction(
                targets: ["\(name)Tests", "\(name)UITests"],
                configurationName: ProjectBuildConfiguration.debugStaging.name
            ),
            runAction: RunAction(configurationName: ProjectBuildConfiguration.debugStaging.name),
            archiveAction: ArchiveAction(configurationName: ProjectBuildConfiguration.releaseStaging.name),
            profileAction: ProfileAction(configurationName: ProjectBuildConfiguration.debugStaging.name),
            analyzeAction: AnalyzeAction(configurationName: ProjectBuildConfiguration.debugStaging.name)
        )
    }
}
