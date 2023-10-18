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
}
