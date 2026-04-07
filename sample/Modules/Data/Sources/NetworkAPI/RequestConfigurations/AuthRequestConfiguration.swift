//
//  AuthRequestConfiguration.swift
//

import Alamofire
import Foundation

/// This is an example of how we handle login/logout with email password via API requests.
enum AuthRequestConfiguration: RequestConfiguration {

    case logIn(username: String, password: String)
    case logOut(accessToken: String)
    case refreshToken(String)

    var baseURL: String { "https://example.com/api" }

    var endpoint: String {
        switch self {
        case .logIn:
            "/auth/login"
        case .logOut:
            "/auth/logout"
        case .refreshToken:
            "/auth/refresh"
        }
    }

    var method: HTTPMethod { .post }

    var encoding: ParameterEncoding { JSONEncoding.default }

    var parameters: Parameters? {
        switch self {
        case let .logIn(username, password):
            [
                "username": username,
                "password": password
            ]
        case let .logOut(accessToken):
            [
                "access_token": accessToken
            ]
        case let .refreshToken(refreshToken):
            [
                "refresh_token": refreshToken
            ]
        }
    }

    var headers: HTTPHeaders? {
        switch self {
        case let .logOut(accessToken):
            [.authorization(bearerToken: accessToken)]
        default:
            nil
        }
    }
}
