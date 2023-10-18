import ProjectDescription

extension Target {
    
    private static let plistsPath: String = "Configurations/Plists"
    
    enum Constant {
        
        static let modulesRootPath: String = "Modules"
        static let sourcesPath: String = "Sources"
        static let resourcesPath: String = "Resources"
    }
    
    public static func mainTarget(name: String, bundleId: String) -> Target {
        return Target(
            name: name,
            platform: .iOS,
            product: .app,
            bundleId: bundleId,
            deploymentTarget: .iOS(
                targetVersion: "{TARGET_VERSION}",
                devices: [.iphone]
            ),
            infoPlist: "\(name)/\(plistsPath)/Info.plist",
            sources: ["\(name)/Sources/**"],
            resources: [
                "\(name)/Resources/**",
                "\(name)/Sources/**/.gitkeep" // To include empty folders
            ],
            scripts: [
                .sourceryScript(),
                .rswiftScript(),
                .swiftLintScript(),
                .swiftFormatLintScript(),
                .firebaseScript()
            ],
            dependencies: [
                .target(name: Module.data.name),
                .target(name: Module.data.name)
            ]
        )
    }
    
    public static func testsTarget(name: String, bundleId: String) -> Target {
        let targetName = "\(name)Tests"
        return Target(
            name: targetName,
            platform: .iOS,
            product: .unitTests,
            bundleId: bundleId,
            infoPlist: "\(targetName)/\(plistsPath)/Info.plist",
            sources: ["\(targetName)/**"],
            resources: [
                "\(targetName)/**/.gitkeep", // To include empty folders
                "\(targetName)/Resources/**/*"
            ],
            scripts: [.swiftFormatScript()],
            dependencies: [.target(name: name)]
        )
    }
    
    public static func kifUITestsTarget(name: String, bundleId: String) -> Target {
        let targetName = "\(name)KIFUITests"
        return Target(
            name: targetName,
            platform: .iOS,
            product: .unitTests,
            bundleId: bundleId,
            infoPlist: "\(targetName)/\(plistsPath)/Info.plist",
            sources: ["\(targetName)/**"],
            resources: [
                "\(targetName)/**/.gitkeep", // To include empty folders
            ],
            dependencies: [.target(name: name)]
        )
    }
    
    public static func makeFramework(module: Module, bundleId: String) -> Target {
        let frameworkPath = "\(Constant.modulesRootPath)/\(module.name)"
        let resourcesElement = ResourceFileElement.glob(pattern: "\(frameworkPath)/\(Constant.resourcesPath)/**")
        
        return Target(
            name: module.name,
            platform: .iOS,
            product: .framework,
            bundleId: bundleId,
            sources: ["\(frameworkPath)/\(Constant.sourcesPath)/**"],
            resources: ResourceFileElements(resources: [resourcesElement]),
            dependencies: module.dependencies
        )
    }
}

//// MARK: - Domain
//
//extension Target {
//
//    public static func domainTarget(bundleId: String) -> Target {
//        return Target(
//            name: "Domain",
//            platform: .iOS,
//            product: .staticLibrary,
//            bundleId: bundleId
//        )
//    }
//
//    public static func domainTestsTarget(bundleId: String) -> Target {
//        return Target(
//            name: "DomainTests",
//            platform: .iOS,
//            product: .unitTests,
//            bundleId: bundleId
//        )
//    }
//}
//
//
//// MARK: - Data
//
//extension Target {
//
//    public static func domainTarget(bundleId: String) -> Target {
//        let name = "Data"
//        return Target(
//            name: name,
//            platform: .iOS,
//            product: .staticLibrary,
//            bundleId: bundleId,
//            sources: ["\(modulesPath)/\(name)/**"]
//        )
//    }
//
//    public static func domainTestsTarget(bundleId: String) -> Target {
//        return Target(
//            name: "DataTests",
//            platform: .iOS,
//            product: .unitTests,
//            bundleId: bundleId,
//            sources: [""]
//        )
//    }
//}
