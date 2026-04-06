//
//  SessionProtocol.swift
//

/// Represents the current user session.
public protocol SessionProtocol: Sendable {

    var authState: AuthState { get }
    var tokenSet: (any TokenSetProtocol)? { get }
}
