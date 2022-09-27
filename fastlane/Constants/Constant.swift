//
//  Constant.swift
//  FastlaneRunner
//
//  Created by Su Ho on 22/09/2022.
//  Copyright © 2022 Nimble. All rights reserved.
//

enum Constant {

    // MARK: - App Store

    static let appStoreKeyId: String = "<#appStoreKeyId#>"
    static let appStoreIssuerId: String = "<#appStoreIssuerId#>"

    // MARK: - Firebase

    static let stagingFirebaseAppId: String = "<#stagingFirebaseAppId#>"
    static let productionFirebaseAppId: String = "<#productionFirebaseAppId#>"
    static let firebaseTesterGroups: String = "<#group1#>, <#group2#>"

    // MARK: - Match

    static let userName: String = "<#userName#>"
    static let teamId: String = "<#teamId#>"
    static let keychainName: String = "<#keychainName#>"
    static let matchURL: String = "<#matchURL#>"

    // MARK: - Path

    static let outputPath: String = "./Output"
    static let buildPath: String = "\(outputPath)/Build"
    static let derivedDataPath: String = "\(outputPath)/DerivedData"

    // MARK: - Project

    static let stagingBundleId: String = "{BUNDLE_ID_STAGING}"
    static let productionBundleId: String = "{BUNDLE_ID_PRODUCTION}"
    static let projectName: String = "{PROJECT_NAME}"

    // MARK: - Symbol

    static let uploadSymbolsBinaryPath: String = "./Pods/FirebaseCrashlytics/upload-symbols"
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
