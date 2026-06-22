//
//  RemoteConfigDecodable.swift
//

import FirebaseRemoteConfig

public protocol RemoteConfigDecodable: Sendable {

    init(decoder: RemoteConfigDecoder)
}
