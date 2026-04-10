//
//  CheckForceUpdateUseCase.swift
//

import FactoryKit
import Foundation

public protocol CheckForceUpdateUseCaseProtocol: Sendable {

    /// Returns `true` when the installed version is below the remote-configured minimum,
    /// indicating the user must update before continuing.
    func execute() async -> Bool
}

public struct CheckForceUpdateUseCase: CheckForceUpdateUseCaseProtocol {

    @Injected(\.remoteConfigRepository) private var remoteConfigRepository: any RemoteConfigRepository
    private let currentVersion: AppVersion

    public init(
        currentVersion: AppVersion = {
            let string = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
            return AppVersion(string: string) ?? AppVersion(major: 1, minor: 0, patch: 0)
        }()
    ) {
        self.currentVersion = currentVersion
    }

    public func execute() async -> Bool {
        let minimumVersion = await remoteConfigRepository.value(for: .minimumAppVersion)
        return currentVersion < minimumVersion
    }
}
