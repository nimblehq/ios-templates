import ProjectDescription

extension Scheme {

    public static func productionScheme(name: String) -> Scheme {
        let debugConfigName = BuildConfiguration.debugProduction.name
        let releaseConfigName = BuildConfiguration.releaseProduction.name
        let testModules = testSchemes(name)

        return Scheme(
            name: name,
            shared: true,
            buildAction: .buildAction(targets: ["\(name)"]),
            testAction: .targets(testModules, configuration: debugConfigName),
            runAction: .runAction(configuration: debugConfigName),
            archiveAction: .archiveAction(configuration: releaseConfigName),
            profileAction: .profileAction(configuration: debugConfigName),
            analyzeAction: .analyzeAction(configuration: debugConfigName)
        )
    }

    public static func stagingScheme(name: String) -> Scheme {
        let debugConfigName = BuildConfiguration.debugStaging.name
        let releaseConfigName = BuildConfiguration.releaseStaging.name
        let testModules = testSchemes(name)

        return Scheme(
            name: "\(name) Staging",
            shared: true,
            buildAction: .buildAction(targets: ["\(name)"]),
            testAction: .targets(testModules, configuration: debugConfigName),
            runAction: .runAction(configuration: debugConfigName),
            archiveAction: .archiveAction(configuration: releaseConfigName),
            profileAction: .profileAction(configuration: debugConfigName),
            analyzeAction: .analyzeAction(configuration: debugConfigName)
        )
    }

    public static func kifUITestsScheme(name: String) -> Scheme {
        return Scheme(
            name: "\(name)KIFUITests",
            shared: false,
            hidden: true
        )
    }

    private static func testSchemes(_ name: String) -> [TestableTarget] {
        var modules = Module.allCases.map { TestableTarget("\($0.name)\(Constant.testsPath)") }
        modules.append(contentsOf: ["\(name)Tests", "\(name)KIFUITests"])
        return modules
    }
}
