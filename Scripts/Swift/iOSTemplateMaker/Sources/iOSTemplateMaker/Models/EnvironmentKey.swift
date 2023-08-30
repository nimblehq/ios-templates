//
//  EnvironmentKey.swift
//  
//
//  Created by Bliss on 30/8/23.
//

enum EnvironmentKey: String {

    case matchRepo = "MATCH_REPO"
    case stagingFirebaseAppId = "STAGING_FIREBASE_APP_ID"
    case teamId = "TEAM_ID"
    case apiKey = "API_KEY_ID"
    case issuerId = "ISSUER_ID"
    case isCI = "CI"
}

extension EnvironmentValue {

    static func value(for key: EnvironmentKey) -> String? {
        Self.value(for: key.rawValue)
    }
}
