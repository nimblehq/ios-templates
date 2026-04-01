import ProjectDescription

public enum Module: CaseIterable {
    case domain
    case data

    public var name: String {
        switch self {
        case .domain: "Domain"
        case .data: "Data"
        }
    }

    public var dependencies: [TargetDependency] {
        switch self {
        case .domain: []
        case .data:
            // Data depends on Domain and Alamofire
            [
                .target(name: Module.domain.name),
                .package(product: "Alamofire")
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

    public var testDependencies: [TargetDependency] {
        switch self {
        case .domain:
            []
        case .data:
            [
                .package(product: "Alamofire"),
                .package(product: "OHHTTPStubsSwift")
            ]
        }
    }

    public func bundleId(mainBundleId: String) -> String {
        "\(mainBundleId).\(name)"
    }

    public func testBundleId(mainBundleId: String) -> String {
        "\(mainBundleId).\(name).tests"
    }
}
