//
//  Secret.swift
//  FastlaneRunner
//
//  Created by Su Ho on 22/09/2022.
//  Copyright © 2022 Nimble. All rights reserved.
//

// This file will be added manually from CI platform (Github Actions / Bitrise / ...)
enum Secret {

    static let keychainPassword = EnvironmentParser.string(key: "KEYCHAIN_PASSWORD")

    static let appstoreConnectAPIKey = EnvironmentParser.string(key: "APPSTORE_CONNECT_API_KEY")

    static let appStoreKeyIdKey = EnvironmentParser.string(key: "API_KEY_ID")

    static let appStoreIssuerIdKey = EnvironmentParser.string(key: "ISSUER_ID")

    static let bumpAppStoreBuildNumber = EnvironmentParser.bool(key: "BUMP_APP_STORE_BUILD_NUMBER")

    static let devices = EnvironmentParser.string(key: "DEVICES")

    static let platform = EnvironmentParser.string(key: "PLATFORM")
}
