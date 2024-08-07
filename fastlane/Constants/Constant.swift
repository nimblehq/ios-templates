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

    static let testFlightTesterGroups = ["<#group1#>", "<#group2#>"]

    // MARK: - Firebase

    static let stagingFirebaseAppId = "<#stagingFirebaseAppId#>"
    static let productionFirebaseAppId = "<#productionFirebaseAppId#>"
    static let firebaseTesterGroups = "<#group1#>, <#group2#>"

    // MARK: - Match

    static let appleStagingUserName = "<#userName#>"
    static let appleStagingTeamId = "<#teamId#>"
    static let appleProductionUserName = "<#userName#>"
    static let appleProductionTeamId = "<#teamId#>"
    static let keychainName = "{PROJECT_NAME}_keychain"
    static let matchURL = "git@github.com:{organization}/{repo}.git"
    static let apiKey: [String: Any] = {
        var key = Secret.appstoreConnectAPIKey
        if let data = Data(base64Encoded: Secret.appstoreConnectAPIKey),
           let decodedKey = String(data: data, encoding: .utf8) {
            key = decodedKey
        }

        return [
            "key_id" : Secret.appStoreKeyIdKey,
            "issuer_id": Secret.appStoreIssuerIdKey,
            "key": key,
            "in_house": false
        ]
    }()

    // MARK: - Path

    static let outputPath = "./Output"
    static let buildPath = "\(outputPath)/Build"
    static let derivedDataPath = "\(outputPath)/DerivedData"
    static let projectPath: String = "./\(projectName).xcodeproj"
    static let testOutputDirectoryPath = "./fastlane/test_output"
    static let infoPlistPath = "\(projectName)/Configurations/Plists/Info.plist"

    // MARK: Platform

    static var platform: PlatformType {
        if EnvironmentParser.bool(key: "CM_BRANCH") {
            return .codeMagic
        } else if EnvironmentParser.bool(key: "BITRISE_IO") {
            return .bitrise
        } else if EnvironmentParser.bool(key: "GITHUB_ACTIONS") {
            return .gitHubActions
        }
        return .unknown
    }

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

    static let devices = ["iPhone 15 Pro"]
}

extension Constant {

    enum Environment: String {

        case staging = "Staging"
        case production = "Production"

        var productName: String { "\(Constant.projectName) \(rawValue)".trimmed }

        var scheme: String {
            switch self {
            case .staging: return "\(Constant.projectName) \(rawValue)".trimmed
            case .production: return Constant.projectName.trimmed
            }
        }

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

        var appleUsername: String {
            switch self {
            case .staging: return Constant.appleStagingUserName
            case .production: return Constant.appleProductionUserName
            }
        }

        var appleTeamId: String {
            switch self {
            case .staging: return Constant.appleStagingTeamId
            case .production: return Constant.appleProductionTeamId
            }
        }
    }

    enum BuildType: String {

        case development
        case adHoc = "ad-hoc"
        case appStore = "app-store"

        var value: String { return rawValue }

        var match: String {
            switch self {
            case .development: return "development"
            case .adHoc: return "adhoc"
            case .appStore: return "appstore"
            }
        }

        var configuration: String {
            switch self {
            case .development: return "Debug"
            case .adHoc, .appStore: return "Release"
            }
        }

        var codeSignIdentity: String {
            switch self {
            case .development: return "iPhone Developer"
            case .adHoc, .appStore: return "iPhone Distribution"
            }
        }

        var method: String {
            switch self {
            case .development: return "Development"
            case .adHoc: return "AdHoc"
            case .appStore: return "AppStore"
            }
        }
    }

    enum PlatformType {

        case gitHubActions, bitrise, codeMagic, unknown
    }
}

extension String {

    fileprivate var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}
