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
