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
                configurationName: "Debug"
            ),
            runAction: RunAction(configurationName: "Debug"),
            archiveAction: ArchiveAction(configurationName: "Release"),
            profileAction: ProfileAction(configurationName: "Debug"),
            analyzeAction: AnalyzeAction(configurationName: "Debug")
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
                configurationName: "Debug"
            ),
            runAction: RunAction(configurationName: "Debug"),
            archiveAction: ArchiveAction(configurationName: "Release"),
            profileAction: ProfileAction(configurationName: "Debug"),
            analyzeAction: AnalyzeAction(configurationName: "Debug")
        )
    }
}
