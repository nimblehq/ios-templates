import ProjectDescription

public enum Module: CaseIterable {

    case data
    case domain
    case model

    public var name: String {
        switch self {
        case .data: "Data"
        case .domain: "Domain"
        case .model: "Model"
        }
    }

    public var dependencies: [TargetDependency] {
        switch self {
        case .model: []
        case .domain:
            [
                .target(name: Module.model.name)
            ]
        case .data:
            [
                .target(name: Module.domain.name),
                .target(name: Module.model.name),
                .package(product: "Alamofire"),
                .package(product: "KeychainAccess"),
                .package(product: "FactoryKit")
            ]
        }
    }

    private var frameworkPath: String {
        "\(Constant.modulesRootPath)/\(name)"
    }

    public var sources: ProjectDescription.SourceFilesList {
        ["\(frameworkPath)/\(Constant.sourcesPath)/**"]
    }

    public var resources: ProjectDescription.ResourceFileElements {
        []
    }

    public var testsSources: ProjectDescription.SourceFilesList {
        ["\(frameworkPath)/\(Constant.testsPath)/**"]
    }

    public var testsResources: ProjectDescription.ResourceFileElements {
        [
            "\(frameworkPath)/\(Constant.testsPath)/\(Constant.resourcesPath)/**",
            "\(frameworkPath)/\(Constant.testsPath)/**/.gitkeep"
        ]
    }

    public func bundleId(mainBundleId: String) -> String {
        "\(mainBundleId).\(name)"
    }

    public func testBundleId(mainBundleId: String) -> String {
        "\(mainBundleId).\(name).tests"
    }
}
