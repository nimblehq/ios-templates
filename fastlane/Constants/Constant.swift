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

    static let bundleId: String = "<#bundleId#>"
    static let productName: String = "<#productName#>"
    static let scheme: String = "<#scheme#>"

    // MARK: - Path

    static let derivedDataPath: String = "./DerivedData"
    static let buildPath: String = "./Build"

    // MARK: - Firebase

    static let firebaseAppIdStaging: String = "<#firebaseAppIdStaging#>"
    static let firebaseAppIdProduction: String = "<#firebaseAppIdProduction#>"
    static let firebaseTesterGroups: String = "<#group1#>, <#group2#>"
}

extension Constant {

    enum Environment: String {

        case staging = "Staging"
        case production = ""

        var productName: String { "\(Constant.productName) \(rawValue)".trimmed }

        var scheme: String { "\(Constant.scheme) \(rawValue)".trimmed }

        var bundleId: String {
            let bundleId = Constant.bundleId
            switch self {
            case .staging: return "\(Constant.bundleId).\(rawValue.lowercased())"
            case .production: return bundleId
            }
        }

        var firebaseAppId: String {
            switch self {
            case .staging: return Constant.firebaseAppIdStaging
            case .production: return Constant.firebaseAppIdProduction
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
