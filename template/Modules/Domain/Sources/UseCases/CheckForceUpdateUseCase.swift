//
//  CheckForceUpdateUseCase.swift
//

import Foundation

public protocol CheckForceUpdateUseCaseProtocol: Sendable {

    /// Returns `true` when the installed version is below the remote-configured minimum,
    /// indicating the user must update before continuing.
    func callAsFunction() async -> Bool
}

public struct CheckForceUpdateUseCase: CheckForceUpdateUseCaseProtocol, Sendable {

    private let remoteConfigRepository: any RemoteConfigRepository
    private let currentVersion: AppVersion

    public init(
        remoteConfigRepository: any RemoteConfigRepository,
        currentVersion: AppVersion = Self.defaultCurrentVersion()
    ) {
        self.remoteConfigRepository = remoteConfigRepository
        self.currentVersion = currentVersion
    }

    public func callAsFunction() async -> Bool {
        let minimumVersion = await remoteConfigRepository.value(for: .minimumAppVersion)
        return currentVersion < minimumVersion
    }
}

private extension CheckForceUpdateUseCase {

    static func defaultCurrentVersion() -> AppVersion {
        let string = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        return AppVersion(string: string) ?? AppVersion(major: 1, minor: 0, patch: 0)
    }
}
