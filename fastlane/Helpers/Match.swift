//
//  Match.swift
//  FastlaneRunner
//
//  Created by Su Ho on 22/09/2022.
//  Copyright © 2022 Nimble. All rights reserved.
//

enum Match {
    
    static func syncCodeSigning(type: MatchType, environment: Environment, isForce: Bool = false) {
        if isCi() {
            Keychain.create()
            match(
                type: type.value,
                readonly: .userDefined(!isForce),
                appIdentifier: [environment.bundleId],
                username: .userDefined(Constant.userName),
                teamId: .userDefined(Constant.teamId),
                gitUrl: Constant.matchURL,
                keychainName: Constant.keychainName,
                keychainPassword: .userDefined(Secret.keychainPassword),
                force: .userDefined(isForce)
            )
        } else {
            match(
                type: type.value,
                readonly: .userDefined(!isForce),
                appIdentifier: [environment.bundleId],
                username: .userDefined(Constant.userName),
                teamId: .userDefined(Constant.teamId),
                gitUrl: Constant.matchURL,
                force: .userDefined(isForce)
            )
        }
        updateCodeSigning(type: type, environment: environment)
    }
    
    static func updateCodeSigning(type: MatchType, environment: Environment) {
        // Update Code signing from automatic to manual
        updateCodeSigningSettings(
            path: Constant.projectPath,
            useAutomaticSigning: .userDefined(false),
            teamId: .userDefined(Constant.teamId),
            targets: .userDefined([Constant.projectName]),
            buildConfigurations: .userDefined(["\(type.buildConfiguration) \(environment.rawValue)"]),
            codeSignIdentity: .userDefined(type.codeSignIdentity),
            profileName: .userDefined("match \(type.method) \(environment.bundleId)")
        )
    }
}

extension Match {
    
    enum Environment: String {
        
        case staging = "Staging"
        case production = "Production"
        
        var bundleId: String {
            switch self {
            case .staging: return Constant.stagingBundleId
            case .production: return Constant.productionBundleId
            }
        }
    }
    
    enum MatchType: String {
        
        case development
        case adHoc = "adhoc"
        case appStore = "appstore"
        
        var value: String { return rawValue }
        
        var method: String {
            switch self {
            case .development: return "Development"
            case .adHoc: return "AdHoc"
            case .appStore: return "AppStore"
            }
        }
        
        var buildConfiguration: String {
            switch self {
            case .development: return "Debug"
            case .adHoc, .appStore: return "Release"
            }
        }
        var codeSignIdentity: String {
            switch self {
            case .development: return "iPhone Developer"
            case .adHoc, . appStore: return "iPhone Distribution"
            }
        }
    }
}
