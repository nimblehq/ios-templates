public protocol SessionProtocol: Sendable {

    var authState: AuthState { get }
    var tokenSet: (any TokenSetProtocol)? { get }
}
