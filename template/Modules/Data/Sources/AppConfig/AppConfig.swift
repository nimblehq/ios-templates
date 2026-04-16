//
//  AppConfig.swift
//

import Combine
import FirebaseRemoteConfig
import Foundation

// MARK: - AppConfigProtocol

public protocol AppConfigProtocol<DecodedConfig> {

    associatedtype DecodedConfig

    var currentConfigPublisher: AnyPublisher<DecodedConfig, Never> { get }
    var currentConfig: DecodedConfig { get }

    func setUp()
    func getAllKeysFromDefault() -> [String]
    func getAllKeysFromRemote() -> [String]
}

// MARK: - AppConfig

/// A generic Firebase Remote Config manager.
public final class AppConfig<DecodedConfig: Sendable>: AppConfigProtocol {

    private var remoteConfig: RemoteConfig?
    private let defaultConfig: AppDefaultConfig
    private let configMapper: (RemoteConfigDecoder) -> DecodedConfig

    public let currentConfigSubject: CurrentValueSubject<DecodedConfig, Never>

    public var currentConfigPublisher: AnyPublisher<DecodedConfig, Never> {
        currentConfigSubject.eraseToAnyPublisher()
    }

    public var currentConfig: DecodedConfig {
        currentConfigSubject.value
    }

    public init(
        defaultConfig: AppDefaultConfig = AppDefaultConfig(),
        initialConfig: DecodedConfig,
        configMapper: @escaping (RemoteConfigDecoder) -> DecodedConfig
    ) {
        self.defaultConfig = defaultConfig
        self.configMapper = configMapper
        currentConfigSubject = CurrentValueSubject(initialConfig)
    }

    public func setUp() {
        remoteConfig = RemoteConfig.remoteConfig()
        setUpConfigSettings()
        setUpDefaults()
        setUpListener()
        fetchAndActivate()
    }

    public func getAllKeysFromDefault() -> [String] {
        remoteConfig?.allKeys(from: .default) ?? []
    }

    public func getAllKeysFromRemote() -> [String] {
        remoteConfig?.allKeys(from: .remote) ?? []
    }
}

// MARK: - Firebase wiring

extension AppConfig {

    private func setUpConfigSettings() {
        let settings = RemoteConfigSettings()
        #if DEBUG || DEV
            settings.minimumFetchInterval = .zero
        #endif
        remoteConfig?.configSettings = settings
    }

    private func setUpDefaults() {
        do {
            try remoteConfig?.setDefaults(from: defaultConfig)
        } catch {
            #if DEBUG || DEV
                NSLog("[AppConfig] Failed to set defaults: \(error).")
            #endif
        }
    }

    private func setUpListener() {
        remoteConfig?.addOnConfigUpdateListener { [weak self] _, error in
            guard let self else { return }
            if logError(error, context: "Listener update") { return }
            remoteConfig?.activate { [weak self] _, error in
                guard let self else { return }
                if logError(error, context: "Listener activate") { return }
                publishUpdatedConfig()
            }
        }
    }

    private func fetchAndActivate() {
        remoteConfig?.fetchAndActivate { [weak self] _, error in
            guard let self else { return }
            if logError(error, context: "Fetch and activate") { return }
            publishUpdatedConfig()
        }
    }

    private func publishUpdatedConfig() {
        guard let remoteConfig else { return }
        let decoder = RemoteConfigDecoder(remoteConfig: remoteConfig)
        currentConfigSubject.send(configMapper(decoder))
    }

    @discardableResult
    private func logError(_ error: (any Error)?, context: String) -> Bool {
        guard let error else { return false }
        #if DEBUG || DEV
            NSLog("[AppConfig] \(context) failed: \(error).")
        #endif
        return true
    }
}