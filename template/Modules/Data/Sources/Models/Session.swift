import Model

/// An internal struct for Data layer to store in Keychain and process the data
struct Session: SessionProtocol {

    let authState: AuthState
    let tokenSet: (any TokenSetProtocol)?
}
