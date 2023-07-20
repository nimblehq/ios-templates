//
//  Match.swift
//  FastlaneRunner
//
//  Created by Su Ho on 22/09/2022.
//  Copyright © 2022 Nimble. All rights reserved.
//

enum Match {

    static func syncCodeSigning(type: Constant.BuildType, environment: Constant.Environment, isForce: Bool = false) {
        match(
            type: type.match,
            readonly: .userDefined(!isForce),
            appIdentifier: [environment.bundleId],
            username: .userDefined(environment.appleUsername),
            teamId: .userDefined(environment.appleTeamId),
            gitUrl: Constant.matchURL,
            force: .userDefined(isForce)
        )
        updateCodeSigning(type: type, environment: environment)
    }
    
    static func updateCodeSigning(type: Constant.BuildType, environment: Constant.Environment) {
        // Update Code signing from automatic to manual
        updateCodeSigningSettings(
            path: Constant.projectPath,
            useAutomaticSigning: .userDefined(false),
            teamId: .userDefined(environment.appleTeamId),
            targets: .userDefined([Constant.projectName]),
            buildConfigurations: .userDefined([Self.createBuildConfiguration(type: type, environment: environment)]),
            codeSignIdentity: .userDefined(type.codeSignIdentity),
            profileName: .userDefined(Self.createProfileName(type: type, environment: environment))
        )
    }
    
    static func createBuildConfiguration(type: Constant.BuildType, environment: Constant.Environment) -> String {
        "\(type.configuration) \(environment.rawValue)"
    }
    
    static func createProfileName(type: Constant.BuildType, environment: Constant.Environment) -> String {
        "match \(type.method) \(environment.bundleId)"
    }
}
