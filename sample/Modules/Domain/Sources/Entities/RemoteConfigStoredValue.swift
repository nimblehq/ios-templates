//
//  RemoteConfigStoredValue.swift
//

import Foundation

public enum RemoteConfigStoredValue: Equatable, Sendable {

    case bool(Bool)
    case string(String)
    case int(Int)
    case double(Double)
    case data(Data)
}
