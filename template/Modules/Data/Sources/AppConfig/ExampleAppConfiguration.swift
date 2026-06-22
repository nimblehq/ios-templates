//
//  ExampleAppConfiguration.swift
//

import Foundation

public enum ExampleConfigKey: String, CodingKey {

  case isFeatureEnabled = "feature_enabled"
  case maxRetryCount = "max_retry_count"
  case apiTimeout = "api_timeout"
  case welcomeMessage = "welcome_message"
}

public struct ExampleAppConfiguration: RemoteConfigDecodable {

  public let isFeatureEnabled: Bool
  public let maxRetryCount: Int
  public let apiTimeout: Double
  public let welcomeMessage: String

  public init(
    isFeatureEnabled: Bool = false,
    maxRetryCount: Int = 3,
    apiTimeout: Double = 30.0,
    welcomeMessage: String = "Welcome to {PROJECT_NAME}"
  ) {
    self.isFeatureEnabled = isFeatureEnabled
    self.maxRetryCount = maxRetryCount
    self.apiTimeout = apiTimeout
    self.welcomeMessage = welcomeMessage
  }

  public init(decoder: RemoteConfigDecoder) {
    let bootstrap = ExampleAppConfiguration()
    self.init(
      isFeatureEnabled: decoder.decodeBool(forKey: ExampleConfigKey.isFeatureEnabled.rawValue)
        ?? bootstrap.isFeatureEnabled,
      maxRetryCount: decoder.decodeNumber(forKey: ExampleConfigKey.maxRetryCount.rawValue)?.intValue
        ?? bootstrap.maxRetryCount,
      apiTimeout: decoder.decodeNumber(forKey: ExampleConfigKey.apiTimeout.rawValue)?.doubleValue
        ?? bootstrap.apiTimeout,
      welcomeMessage: decoder.decodeString(forKey: ExampleConfigKey.welcomeMessage.rawValue)
        ?? bootstrap.welcomeMessage
    )
  }

  public static func makeAppConfig() -> AppConfig<ExampleAppConfiguration> {
    let bootstrap = ExampleAppConfiguration()
    let remoteDefaults = AppDefaultConfig.build(configs: [
      ExampleConfigKey.isFeatureEnabled.rawValue: bootstrap.isFeatureEnabled,
      ExampleConfigKey.maxRetryCount.rawValue: bootstrap.maxRetryCount,
      ExampleConfigKey.apiTimeout.rawValue: bootstrap.apiTimeout,
      ExampleConfigKey.welcomeMessage.rawValue: bootstrap.welcomeMessage,
    ])
    return AppConfig(
      remoteConfigDefaults: remoteDefaults,
      bootstrapDecodedConfig: bootstrap,
      configMapper: { self.init(decoder: $0) }
    )
  }
}   
