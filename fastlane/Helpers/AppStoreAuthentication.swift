//
//  AppStoreAuthentication.swift
//  FastlaneRunner
//
//  Created by Su T. on 28/09/2022.
//  Copyright © 2022 Nimble. All rights reserved.
//

import Foundation

enum AppStoreAuthentication {

    static func connectAPIKey() {
        appStoreConnectApiKey(
            keyId: Secret.appStoreKeyIdKey,
            issuerId: Secret.appStoreIssuerIdKey,
            keyContent: .userDefined(Secret.appstoreConnectAPIKey),
            isKeyContentBase64: .userDefined(true) // Check if the AppStore Connect API Key is base64
        )
    }
}
