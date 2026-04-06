//
//  AuthState.swift
//

public enum AuthState: Sendable, Equatable {

    case unauthenticated
    case authenticated
    case expired
}
