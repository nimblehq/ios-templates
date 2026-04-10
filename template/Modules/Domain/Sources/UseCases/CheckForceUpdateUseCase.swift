//
//  CheckForceUpdateUseCase.swift
//

import Foundation

public protocol CheckForceUpdateUseCaseProtocol: Sendable {

    /// Returns `true` when the installed version is below the remote-configured minimum,
    /// indicating the user must update before continuing.
    func callAsFunction() async -> Bool
}

private func defaultCurrentVersion() -> AppVersion {
    let string = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    return AppVersion(string: string) ?? AppVersion(major: 1, minor: 0, patch: 0)
}

struct CheckForceUpdateUseCase: CheckForceUpdateUseCaseProtocol, Sendable {

    private let remoteConfigRepository: any RemoteConfigRepository
    private let currentVersion: AppVersion

    init(remoteConfigRepository: any RemoteConfigRepository, currentVersion: AppVersion = defaultCurrentVersion()) {
        self.remoteConfigRepository = remoteConfigRepository
        self.currentVersion = currentVersion
    }

    func callAsFunction() async -> Bool {
        let minimumVersion = await remoteConfigRepository.value(for: .minimumAppVersion)
        return currentVersion < minimumVersion
    }
}

public func makeCheckForceUpdateUseCase(
    remoteConfigRepository: any RemoteConfigRepository,
    currentVersion: AppVersion = defaultCurrentVersion()
) -> any CheckForceUpdateUseCaseProtocol {
    CheckForceUpdateUseCase(
        remoteConfigRepository: remoteConfigRepository,
        currentVersion: currentVersion
    )
}
