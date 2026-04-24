/// Example analytics event for user login
public struct UserLoginEvent: AnalyticsEvent {
    
    public let name = "user_login"
    
    public let loginMethod: String
    public let isSuccessful: Bool
    
    public init(loginMethod: String, isSuccessful: Bool = true) {
        self.loginMethod = loginMethod
        self.isSuccessful = isSuccessful
    }
    
    public var parameters: [String: Any]? {
        return [
            "login_method": loginMethod,
            "is_successful": isSuccessful
        ]
    }
}
