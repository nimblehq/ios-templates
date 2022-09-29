//
//  Symbol.swift
//  FastlaneRunner
//
//  Created by Su Ho on 27/09/2022.
//  Copyright © 2022 Nimble. All rights reserved.
//

import Foundation

enum Symbol {

    static func uploadAdhocToCrashlytics(environment: Constant.Environment) {
        guard FileManager.default.fileExists(atPath: environment.dsymPath) else {
            return log(message: "Can't find the dSYM file")
        }
        uploadSymbolsToCrashlytics(
            dsymPath: environment.dsymPath,
            gspPath: .userDefined(environment.gspPath),
            appId: .userDefined(environment.firebaseAppId),
            binaryPath: .userDefined(Constant.uploadSymbolsBinaryPath),
            debug: true // We sometimes has issues with dSYM files, so I enabled this flag.
        )
    }

    static func uploadAppStoreToCrashlytics(
        versionNumber: String,
        buildNumber: String,
        environment: Constant.Environment = .production
    ) {
        // This file name from download_dsyms action
        // https://github.com/fastlane/fastlane/blob/master/fastlane/lib/fastlane/actions/download_dsyms.rb#L183
        let dsymFileName = "\(environment.bundleId)-\(versionNumber)-\(buildNumber)\(Constant.dSYMSuffix)"
        let outputDirectoryURL = URL(fileURLWithPath: Constant.outputPath)
        let dsymPath = outputDirectoryURL.appendingPathComponent(dsymFileName).relativePath
        guard FileManager.default.fileExists(atPath: dsymPath) else {
            return log(message: "Can't find the dSYM file")
        }
        uploadSymbolsToCrashlytics(
            dsymPath: dsymPath,
            gspPath: .userDefined(environment.gspPath),
            appId: .userDefined(environment.firebaseAppId),
            binaryPath: .userDefined(Constant.uploadSymbolsBinaryPath),
            debug: true // We sometimes has issues with dSYM files, so I enabled this flag.
        )
    }

    static func downloadFromAppStore(
        versionNumber: String,
        buildNumber: String,
        environment: Constant.Environment = .production
    ) {
        // Create output directory if needed
        let outputDirectoryURL = URL(fileURLWithPath: Constant.outputPath)
        do {
            try FileManager.default.createDirectory(atPath: outputDirectoryURL.relativePath, withIntermediateDirectories: true)
        } catch {
            log(message: "Having issues \(error.localizedDescription) when creating directory \(Constant.outputPath)")
        }

        downloadDsyms(
            username: Constant.userName,
            appIdentifier: environment.bundleId,
            teamId: .userDefined(Constant.teamId),
            version: .userDefined(versionNumber),
            buildNumber: .userDefined(buildNumber),
            outputDirectory: .userDefined(Constant.outputPath),
            waitForDsymProcessing: .userDefined(true)
        )
    }
}
