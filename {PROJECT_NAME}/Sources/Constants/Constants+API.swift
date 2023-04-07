//  swiftlint:disable:this file_name
//
//  Constants+API.swift
//

import ArkanaKeys

extension Constants.API {
    
#if STAGING
    static let clientId: String = ArkanaKeys.Keys.Staging().clientId
    static let clientSecret: String = ArkanaKeys.Keys.Staging().clientSecret
#elseif PRODUCTION
    static let clientId: String = ArkanaKeys.Keys.Release().clientId
    static let clientSecret: String = ArkanaKeys.Keys.Release().clientSecret
#endif
}
