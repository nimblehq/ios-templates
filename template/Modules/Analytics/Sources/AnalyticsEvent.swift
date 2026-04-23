public protocol AnalyticsEvent {
    
    var name: String { get }
    var parameters: [String: Any]? { get }
}
