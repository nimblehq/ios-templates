//
//  Distribution.swift
//  FastlaneRunner
//
//  Created by Su T. on 25/09/2022.
//  Copyright © 2022 Nimble. All rights reserved.
//

import Foundation

final class Distribution {

    static func uploadToFirebase(
        environment: Constant.Environment,
        groups: String = Constant.firebaseTesterGroups,
        releaseNotes: String
    ) {
        let ipaPath = "\(Constant.outputPath)/\(environment.productName).ipa"
        firebaseAppDistribution(
            ipaPath: .userDefined(ipaPath),
            app: .userDefined(environment.firebaseAppId),
            groups: .userDefined(groups),
            releaseNotes: .userDefined(releaseNotes),
            firebaseCliToken: .userDefined(Secret.firebaseCLIToken),
            debug: .userDefined(true)
        )
    }
}
