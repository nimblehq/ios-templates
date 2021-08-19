import ProjectDescription

extension Scheme {

    public static func mainScheme(name: String) -> Scheme {
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