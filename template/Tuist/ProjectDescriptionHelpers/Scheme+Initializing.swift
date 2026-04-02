import ProjectDescription

extension Scheme {
    public static func productionScheme(name: String) -> Scheme {
        let debugConfigName = BuildConfiguration.debugProduction.name
        let releaseConfigName = BuildConfiguration.releaseProduction.name

        return .scheme(
            name: name,
            shared: true,
            buildAction: .buildAction(targets: ["\(name)"]),
            testAction: TestAction.targets([.testableTarget(target: "\(name)Tests")], configuration: debugConfigName),
            runAction: .runAction(configuration: debugConfigName),
            archiveAction: .archiveAction(configuration: releaseConfigName)
        )
    }

    public static func stagingScheme(name: String) -> Scheme {
        let debugConfigName = BuildConfiguration.debugStaging.name
        let releaseConfigName = BuildConfiguration.releaseStaging.name

        return .scheme(
            name: "\(name) Staging",
            shared: true,
            buildAction: .buildAction(targets: ["\(name)"]),
            testAction: TestAction.targets([.testableTarget(target: "\(name)Tests")], configuration: debugConfigName),
            runAction: .runAction(configuration: debugConfigName),
            archiveAction: .archiveAction(configuration: releaseConfigName)
        )
    }
    
    public static func devScheme(name: String) -> Scheme {
        let debugConfigName = BuildConfiguration.debugDev.name
        let releaseConfigName = BuildConfiguration.releaseDev.name

        return .scheme(
            name: "\(name) Dev",
            shared: true,
            buildAction: .buildAction(targets: ["\(name)"]),
            testAction: TestAction.targets([.testableTarget(target: "\(name)Tests")], configuration: debugConfigName),
            runAction: .runAction(configuration: debugConfigName),
            archiveAction: .archiveAction(configuration: releaseConfigName),
        )
    }
}
