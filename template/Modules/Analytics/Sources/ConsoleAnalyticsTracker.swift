import Foundation

/// Console tracker that logs analytics events to the console for debugging
public final class ConsoleAnalyticsTracker: AnalyticsTracker {
    
    public let type: AnalyticsTrackerType
    private let prefix: String
    
    public init(type: AnalyticsTrackerType, logPrefix: String? = nil) {
        self.type = type
        self.prefix = logPrefix ?? "[\(type.rawValue.uppercased())]"
    }
    
    // MARK: - AnalyticsTracker Implementation
    
    public func setUp(additionalParameters: [String: Any]?) {
        let paramsString = additionalParameters?.description ?? "none"
        print("\(prefix) SETUP - Additional parameters: \(paramsString)")
    }
    
    public func trackEvent(name: String, parameters: [String: Any]?) {
        var message = "\(prefix) EVENT - \(name)"
        
        if let parameters = parameters, !parameters.isEmpty {
            let paramsString = parameters.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
            message += " | Parameters: {\(paramsString)}"
        }
        
        print(message)
    }
    
    public func trackScreen(name: String, screenClass: String?) {
        var message = "\(prefix) SCREEN - \(name)"
        
        if let screenClass = screenClass {
            message += " | Class: \(screenClass)"
        }
        
        print(message)
    }
    
    public func setUserProperty(key: String, value: String) {
        print("\(prefix) USER_PROPERTY - \(key): \(value)")
    }
    
    public func setUserId(_ userId: String?) {
        let userIdString = userId ?? "null"
        print("\(prefix) USER_ID - \(userIdString)")
    }
}
