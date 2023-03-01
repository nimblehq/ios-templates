//
//  Match.swift
//  FastlaneRunner
//
//  Created by Su Ho on 22/09/2022.
//  Copyright © 2022 Nimble. All rights reserved.
//

enum Match {

    static func syncCodeSigning(type: MatchType, appIdentifier: [String], isForce: Bool = false) {
        if isCi() {
            Keychain.create()
            match(
                type: type.value,
                readonly: .userDefined(!isForce),
                appIdentifier: appIdentifier,
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
                appIdentifier: appIdentifier,
                username: .userDefined(Constant.userName),
                teamId: .userDefined(Constant.teamId),
                gitUrl: Constant.matchURL,
                force: .userDefined(isForce)
            )
            updateCodeSigning(type: type, appIdentifier: appIdentifier)
        }
    }
    
    static func updateCodeSigning(type: MatchType, appIdentifier: [String]) {
        // Update Code signing from automatic to manual
        switch type {
        case .development:
            updateCodeSigningSettings(
                path: Constant.projectPath,
                useAutomaticSigning: .userDefined(false),
                targets: .userDefined([Constant.projectName]),
                buildConfigurations: .userDefined(["Release Staging"]),
                codeSignIdentity: .userDefined("iPhone Developer"),
                profileName: .userDefined("match AdHoc \(Constant.stagingBundleId)")
            )
        case .adHoc:
            if appIdentifier.first == Constant.productionBundleId {
                updateCodeSigningSettings(
                    path: Constant.projectPath,
                    useAutomaticSigning: .userDefined(false),
                    targets: .userDefined([Constant.projectName]),
                    buildConfigurations: .userDefined(["Debug Production"]),
                    codeSignIdentity: .userDefined("iPhone Distribution"),
                    profileName: .userDefined("match AdHoc \(Constant.productionBundleId)")
                )
            } else {
                updateCodeSigningSettings(
                    path: Constant.projectPath,
                    useAutomaticSigning: .userDefined(false),
                    targets: .userDefined([Constant.projectName]),
                    buildConfigurations: .userDefined(["Release Staging"]),
                    codeSignIdentity: .userDefined("iPhone Distribution"),
                    profileName: .userDefined("match AdHoc \(Constant.stagingBundleId)")
                )
            }
        case .appStore:
            updateCodeSigningSettings(
                path: Constant.projectPath,
                useAutomaticSigning: .userDefined(false),
                targets: .userDefined([Constant.projectName]),
                buildConfigurations: .userDefined(["Release Production"]),
                codeSignIdentity: .userDefined("iPhone Distribution"),
                profileName: .userDefined("match AppStore \(Constant.productionBundleId)")
            )
        }
    }
}

extension Match {

    enum MatchType: String {

        case development
        case adHoc = "adhoc"
        case appStore = "appstore"

        var value: String { return rawValue }
    }
}
