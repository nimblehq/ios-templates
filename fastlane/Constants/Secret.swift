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

    static let firebaseCLIToken = EnvironmentParser.string(key: "FIREBASE_CLI_TOKEN")

    static let appstoreConnectAPIKey = EnvironmentParser.string(key: "APPSTORE_CONNECT_API_KEY")
}
