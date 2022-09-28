//
//  Constant.swift
//  FastlaneRunner
//
//  Created by Su Ho on 22/09/2022.
//  Copyright © 2022 Nimble. All rights reserved.
//

import Foundation

enum Constant {

    // MARK: - App Store

    static let appStoreKeyId = "<#appStoreKeyId#>"
    static let appStoreIssuerId = "<#appStoreIssuerId#>"
    static let testFlightTesterGroups = ["<#group1#>", "<#group2#>"]

    // MARK: - Firebase

    static let stagingFirebaseAppId = "<#stagingFirebaseAppId#>"
    static let productionFirebaseAppId = "<#productionFirebaseAppId#>"
    static let firebaseTesterGroups = "<#group1#>, <#group2#>"

    // MARK: - Match

    static let userName = "<#userName#>"
    static let teamId = "<#teamId#>"
    static let keychainName = "<#keychainName#>"
    static let matchURL = "<#matchURL#>"

    // MARK: - Path

    static let outputPath = "./Output"
    static let buildPath = "\(outputPath)/Build"
    static let derivedDataPath = "\(outputPath)/DerivedData"
    static let projectPath: String = "./\(projectName).xcodeproj"
    static let testOutputDirectoryPath = "./fastlane/test_output"

    // MARK: - Project

    static let stagingBundleId = "{BUNDLE_ID_STAGING}"
    static let productionBundleId = "{BUNDLE_ID_PRODUCTION}"
    static let projectName = "{PROJECT_NAME}"

    // MARK: - Symbol

    static let uploadSymbolsBinaryPath: String = "./Pods/FirebaseCrashlytics/upload-symbols"
    static let dSYMSuffix: String = ".dSYM.zip"
    
    // MARK: - Build and Version

    static let manualVersion: String = ""

    // MARK: - Device

    static let device: String = "iPhone 12 Pro Max"
    
    // MARK: - Test

    static let testTarget: String = "{PROJECT_NAME}Tests"
    static let uiTestTarget: String = "{PROJECT_NAME}UITests"
}

extension Constant {

    enum Environment: String {

        case staging = "Staging"
        case production = ""

        var productName: String { "\(Constant.projectName) \(rawValue)".trimmed }

        var scheme: String { "\(Constant.projectName) \(rawValue)".trimmed }

        var bundleId: String {
            switch self {
            case .staging: return Constant.stagingBundleId
            case .production: return Constant.productionBundleId
            }
        }

        var firebaseAppId: String {
            switch self {
            case .staging: return Constant.stagingFirebaseAppId
            case .production: return Constant.productionFirebaseAppId
            }
        }

        var gspPath: String {
            let infoName = "GoogleService-Info.plist"
            let googleServiceFolder = "./\(Constant.projectName)/Configurations/Plists/GoogleService"
            switch self {
            case .staging: return "\(googleServiceFolder)/Staging/\(infoName)"
            case .production: return "\(googleServiceFolder)/Production/\(infoName)"
            }
        }

        var dsymPath: String {
            let outputDirectoryURL = URL(fileURLWithPath: Constant.outputPath)
            return outputDirectoryURL.appendingPathComponent(productName + ".app" + Constant.dSYMSuffix).relativePath
        }
    }

    enum BuildType: String {

        case adHoc = "ad-hoc"
        case appStore = "app-store"

        var value: String { return rawValue }

        var method: String {
            switch self {
            case .adHoc: return "AdHoc"
            case .appStore: return "AppStore"
            }
        }
    }
}

extension String {

    fileprivate var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}
