import Foundation
public protocol TokenSetProtocol: Sendable {

    var accessToken: String { get }
    var refreshToken: String { get }
    var expiresAt: Date? { get }
    var tokenType: String? { get }
}

extension TokenSetProtocol {

    public var isExpired: Bool {
        guard let expiresAt else { return false }
        return expiresAt <= Date()
    }
}
