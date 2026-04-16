//
//  ExampleAppConfiguration.swift
//

import Foundation

/// Example configuration structure that demonstrates how to use AppConfig.
/// Replace this with your app-specific configuration in real projects.
public struct ExampleAppConfiguration: Sendable {

    public let isFeatureEnabled: Bool
    public let maxRetryCount: Int
    public let apiTimeout: Double
    public let welcomeMessage: String

    public init(
        isFeatureEnabled: Bool = false,
        maxRetryCount: Int = 3,
        apiTimeout: Double = 30.0,
        welcomeMessage: String = "Welcome"
    ) {
        self.isFeatureEnabled = isFeatureEnabled
        self.maxRetryCount = maxRetryCount
        self.apiTimeout = apiTimeout
        self.welcomeMessage = welcomeMessage
    }
}

public enum ExampleConfigKey: String, CodingKey {

    case isFeatureEnabled = "feature_enabled"
    case maxRetryCount = "max_retry_count"
    case apiTimeout = "api_timeout"
    case welcomeMessage = "welcome_message"
}

public func createExampleAppConfig() -> AppConfig<ExampleAppConfiguration> {
    let defaultConfig = AppDefaultConfig.build(configs: [
        ExampleConfigKey.isFeatureEnabled.rawValue: false,
        ExampleConfigKey.maxRetryCount.rawValue: 3,
        ExampleConfigKey.apiTimeout.rawValue: 30.0,
        ExampleConfigKey.welcomeMessage.rawValue: "Welcome to {PROJECT_NAME}"
    ])

    let initialConfig = ExampleAppConfiguration()

    let configMapper: (RemoteConfigDecoder) -> ExampleAppConfiguration = { decoder in
        ExampleAppConfiguration(
            isFeatureEnabled: decoder.decodeBool(forKey: ExampleConfigKey.isFeatureEnabled.rawValue),
            maxRetryCount: decoder.decodeNumber(forKey: ExampleConfigKey.maxRetryCount.rawValue)?.intValue ?? 3,
            apiTimeout: decoder.decodeNumber(forKey: ExampleConfigKey.apiTimeout.rawValue)?.doubleValue ?? 30.0,
            welcomeMessage: decoder.decodeString(forKey: ExampleConfigKey.welcomeMessage.rawValue) ?? "Welcome"
        )
    }

    return AppConfig(
        defaultConfig: defaultConfig,
        initialConfig: initialConfig,
        configMapper: configMapper
    )
}