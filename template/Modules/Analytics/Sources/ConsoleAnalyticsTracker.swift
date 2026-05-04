import Foundation
import os

/// Console tracker that logs analytics events to the console for debugging
public final class ConsoleAnalyticsTracker: AnalyticsTracker {
    
    public let type: AnalyticsTrackerType
    private let prefix: String
    private let logger = Logger(subsystem: "Analytics", category: "ConsoleTracker")
    
    public init(type: AnalyticsTrackerType, logPrefix: String? = nil) {
        self.type = type
        self.prefix = logPrefix ?? "[\(type.rawValue.uppercased())]"
    }
    
    // MARK: - AnalyticsTracker Implementation
    
    public func setUp(additionalParameters: [String: Any]?) {
        if let params = additionalParameters, !params.isEmpty {
            let sortedKeys = params.keys.sorted()
            let paramsString = sortedKeys.map { "\($0): \(params[$0]!)" }.joined(separator: ", ")
            logger.info("\(self.prefix, privacy: .public) SETUP - Additional parameters: \(paramsString, privacy: .private)")
        } else {
            logger.info("\(self.prefix, privacy: .public) SETUP - Additional parameters: none")
        }
    }
    
    public func trackEvent(name: String, parameters: [String: Any]?) {
        if let parameters = parameters, !parameters.isEmpty {
            let paramsString = parameters.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
            logger.info("\(self.prefix, privacy: .public) EVENT - \(name, privacy: .private) | Parameters: {\(paramsString, privacy: .private)}")
        } else {
            logger.info("\(self.prefix, privacy: .public) EVENT - \(name, privacy: .private)")
        }
    }
    
    public func trackScreen(name: String, screenClass: String?) {
        if let screenClass = screenClass {
            logger.info("\(self.prefix, privacy: .public) SCREEN - \(name, privacy: .private) | Class: \(screenClass, privacy: .private)")
        } else {
            logger.info("\(self.prefix, privacy: .public) SCREEN - \(name, privacy: .private)")
        }
    }
    
    public func setUserProperty(key: String, value: String) {
        logger.info("\(self.prefix, privacy: .public) USER_PROPERTY - \(key, privacy: .private): \(value, privacy: .private)")
    }
    
    public func setUserId(_ userId: String?) {
        let userIdString = userId ?? "null"
        logger.info("\(self.prefix, privacy: .public) USER_ID - \(userIdString, privacy: .private)")
    }
}
