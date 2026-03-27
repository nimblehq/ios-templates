import Foundation

public protocol AuthServiceProtocol: AnyObject {

    var currentUser: User? { get }

    func signIn(email: String, password: String) async throws

    func signUp(email: String, password: String) async throws

    func signOut()
}
