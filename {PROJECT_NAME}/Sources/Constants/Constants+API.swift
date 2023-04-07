//  swiftlint:disable:this file_name
//
//  Constants+API.swift
//

extension Constants.API {
    
#if STAGING
    static let clientId: String = {PROJECT_NAME}Keys.Keys.Staging().clientId
    static let clientSecret: String = {PROJECT_NAME}Keys.Keys.Staging().clientSecret
#elseif PRODUCTION
    static let clientId: String = {PROJECT_NAME}Keys.Keys.Release().clientId
    static let clientSecret: String = {PROJECT_NAME}Keys.Keys.Release().clientSecret
#endif
}
