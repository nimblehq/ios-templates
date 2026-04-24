import Testing
@testable import Analytics

@Suite("UserLoginEvent Tests")
struct UserLoginEventTests {
    
    @Test("Create event with correct parameters")
    func createEventWithCorrectParameters() {
        let event = UserLoginEvent(loginMethod: "email", isSuccessful: true)
        
        #expect(event.name == "user_login")
        #expect(event.parameters?["login_method"] as? String == "email")
        #expect(event.parameters?["is_successful"] as? Bool == true)
    }
    
    @Test("Handle failed login")
    func handleFailedLogin() {
        let event = UserLoginEvent(loginMethod: "social", isSuccessful: false)
        
        #expect(event.parameters?["is_successful"] as? Bool == false)
        #expect(event.parameters?["login_method"] as? String == "social")
    }
}
