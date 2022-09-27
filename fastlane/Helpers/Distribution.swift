//
//  Distribution.swift
//  FastlaneRunner
//
//  Created by Su T. on 25/09/2022.
//  Copyright © 2022 Nimble. All rights reserved.
//

import Foundation

enum Distribution {

    static func uploadToFirebase(
        environment: Constant.Environment,
        groups: String = Constant.firebaseTesterGroups,
        releaseNotes: String
    ) {
        let ipaPath = makeIpaPath(environment: environment)
        firebaseAppDistribution(
            ipaPath: .userDefined(ipaPath),
            app: .userDefined(environment.firebaseAppId),
            groups: .userDefined(groups),
            releaseNotes: .userDefined(releaseNotes),
            firebaseCliToken: .userDefined(Secret.firebaseCLIToken),
            debug: .userDefined(true)
        )
    }

    static func uploadToAppStore() {
        let environment: Constant.Environment = .production
        let ipaPath = makeIpaPath(environment: environment)
        appStoreConnectApiKey(
            keyId: Constant.appStoreKeyId,
            issuerId: Constant.appStoreIssuerId,
            keyContent: .userDefined(Secret.appstoreConnectAPIKey),
            isKeyContentBase64: .userDefined(true) // Check if the AppStore Connect API Key is base64
        )
        deliver(
            appIdentifier: .userDefined(environment.bundleId),
            ipa: .userDefined(ipaPath),
            skipScreenshots: .userDefined(true),
            skipMetadata: .userDefined(true),
            force: .userDefined(true),
            runPrecheckBeforeSubmit: .userDefined(false)
        )
    }

    static private func makeIpaPath(environment: Constant.Environment) -> String {
        "\(Constant.outputPath)/\(environment.productName).ipa"
    }
}
