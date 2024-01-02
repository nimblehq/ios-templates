//
//  Modules.swift
//  ProjectDescriptionHelpers
//
//  Created by Phong on 16/10/2023.
//

import ProjectDescription

public enum Module: CaseIterable {

    case domain
    case data

    public var name: String {
        switch self {
        case .domain:
            return "Domain"
        case .data:
            return "Data"
        }
    }

    public var dependencies: [TargetDependency] {
        switch self {
        case .domain:
            return []
        case .data:
            return [.target(name: Module.domain.name)]
        }
    }

    public var frameworkPath: String {
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
            "\(frameworkPath)/\(Constant.testsPath)/**/.gitkeep",
            "\(frameworkPath)/\(Constant.testsPath)/\(Constant.resourcesPath)/**"
        ]
    }


    public func getBundleId(mainBundleId: String) -> String {
        "\(mainBundleId).\(name)"
    }

    public func getTestBundleId(mainBundleId: String) -> String {
        "\(mainBundleId).\(name)\(Constant.testsPath)"
    }
}
