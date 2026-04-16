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
    private var configUpdateListenerRegistration: ConfigUpdateListenerRegistration?
    private var didSetUp = false
    private let remoteConfigDefaults: AppDefaultConfig
    private let configMapper: (RemoteConfigDecoder) -> DecodedConfig
    private let currentConfigSubject: CurrentValueSubject<DecodedConfig, Never>

    deinit {
        configUpdateListenerRegistration?.remove()
    }

    public var currentConfigPublisher: AnyPublisher<DecodedConfig, Never> {
        currentConfigSubject.eraseToAnyPublisher()
    }

    public var currentConfig: DecodedConfig {
        currentConfigSubject.value
    }

    public init(
        remoteConfigDefaults: AppDefaultConfig = AppDefaultConfig(),
        bootstrapDecodedConfig: DecodedConfig,
        configMapper: @escaping (RemoteConfigDecoder) -> DecodedConfig
    ) {
        self.remoteConfigDefaults = remoteConfigDefaults
        self.configMapper = configMapper
        currentConfigSubject = CurrentValueSubject(bootstrapDecodedConfig)
    }

    public func setUp() {
        guard !didSetUp else { return }
        didSetUp = true
        // Uncomment after we set up firebase remote config
//        remoteConfig = RemoteConfig.remoteConfig()
        setUpConfigSettings()
        setUpDefaults()
        setUpListener()
        fetchAndActivate()
    }

    public func getAllKeysFromDefault() -> [String] {
        if let remoteConfig {
            return remoteConfig.allKeys(from: .default).sorted()
        }
        return remoteConfigDefaults.configs.keys.map(\.stringValue).sorted()
    }

    public func getAllKeysFromRemote() -> [String] {
        remoteConfig?.allKeys(from: .remote).sorted() ?? []
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
            try remoteConfig?.setDefaults(from: remoteConfigDefaults)
        } catch {
            #if DEBUG || DEV
                NSLog("[AppConfig] Failed to set defaults: \(error).")
            #endif
        }
    }

    private func setUpListener() {
        configUpdateListenerRegistration = remoteConfig?.addOnConfigUpdateListener { [weak self] _, error in
            guard let self else { return }
            if logError(error, context: "Listener update") { return }
            remoteConfig?.activate { [weak self] _, error in
                guard let self else { return }
                _ = logError(error, context: "Listener activate")
                publishUpdatedConfig()
            }
        }
    }

    private func fetchAndActivate() {
        remoteConfig?.fetchAndActivate { [weak self] _, error in
            guard let self else { return }
            _ = logError(error, context: "Fetch and activate")
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
