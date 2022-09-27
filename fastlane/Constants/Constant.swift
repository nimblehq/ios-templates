//
//  Constant.swift
//  FastlaneRunner
//
//  Created by Su Ho on 22/09/2022.
//  Copyright © 2022 Nimble. All rights reserved.
//

enum Constant {

    // MARK: - Match

    static let userName: String = "<#userName#>"
    static let teamId: String = "<#teamId#>"
    static let keychainName: String = "<#keychainName#>"
    static let matchURL: String = "<#matchURL#>"

    // MARK: - Project

    static let stagingBundleId: String = "<#stagingBundleId#>"
    static let productionBundleId: String = "<#productionBundleId#>"
    static let productName: String = "<#productName#>"
    static let scheme: String = "<#scheme#>"

    // MARK: - Path

    static let outputPath: String = "./Output"
    static let buildPath: String = "\(outputPath)/Build"
    static let derivedDataPath: String = "\(outputPath)/DerivedData"

    // MARK: - Firebase

    static let stagingFirebaseAppId: String = "<#stagingFirebaseAppId#>"
    static let productionFirebaseAppId: String = "<#productionFirebaseAppId#>"
    static let firebaseTesterGroups: String = "<#group1#>, <#group2#>"
}

extension Constant {

    enum Environment: String {

        case staging = "Staging"
        case production = ""

        var productName: String { "\(Constant.productName) \(rawValue)".trimmed }

        var scheme: String { "\(Constant.scheme) \(rawValue)".trimmed }

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
