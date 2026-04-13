//
//  LoadStartupConfigUseCase.swift
//

public protocol LoadStartupConfigUseCaseProtocol: Sendable {

    func callAsFunction() async throws(CancellationError) -> StartupConfigLoadResult
}

public struct LoadStartupConfigUseCase: LoadStartupConfigUseCaseProtocol, Sendable {

    private let remoteConfigRepository: any RemoteConfigRepository

    public init(remoteConfigRepository: any RemoteConfigRepository) {
        self.remoteConfigRepository = remoteConfigRepository
    }

    public func callAsFunction() async throws(CancellationError) -> StartupConfigLoadResult {
        do {
            try await remoteConfigRepository.refresh()
            return .refreshed
        } catch let error as CancellationError {
            throw error
        } catch {
            return .usedLocalDefaults
        }
    }
}
