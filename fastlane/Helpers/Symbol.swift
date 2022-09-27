//
//  Symbol.swift
//  FastlaneRunner
//
//  Created by Su Ho on 27/09/2022.
//  Copyright © 2022 Nimble. All rights reserved.
//

import Foundation

enum Symbol {

    static func uploadToCrashlytics(environment: Constant.Environment) {
        let buildURL = URL(fileURLWithPath: Constant.outputPath)
        let dsymURL = buildURL.appendingPathComponent(environment.productName + ".app.dSYM.zip")
        guard FileManager.default.fileExists(atPath: dsymURL.relativePath) else {
            return log(message: "Can't find the dSYM file")
        }
        uploadSymbolsToCrashlytics(
            dsymPath: dsymURL.relativePath,
            gspPath: .userDefined(environment.gspPath),
            appId: .userDefined(environment.firebaseAppId),
            binaryPath: .userDefined(Constant.uploadSymbolsBinaryPath),
            debug: true // We sometimes has issues with dSYM files, so I enabled this flag.
        )
    }
}
