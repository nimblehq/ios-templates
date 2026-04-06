//
//  Session.swift
//

import Domain

struct Session: SessionProtocol {

    let authState: AuthState
    let tokenSet: (any TokenSetProtocol)?

    init(authState: AuthState, tokenSet: (any TokenSetProtocol)? = nil) {
        self.authState = authState
        self.tokenSet = tokenSet
    }
}
