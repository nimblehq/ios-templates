import Foundation

public struct User: Equatable {
    public let email: String

    public init(email: String) {
        self.email = email
    }
}
