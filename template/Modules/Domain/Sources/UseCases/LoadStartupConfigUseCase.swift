//
//  LoadStartupConfigUseCase.swift
//

public protocol LoadStartupConfigUseCaseProtocol: Sendable {

    func execute() async throws -> StartupConfigLoadResult
}

struct LoadStartupConfigUseCase: LoadStartupConfigUseCaseProtocol, Sendable {

    private let remoteConfigRepository: any RemoteConfigRepository

    init(remoteConfigRepository: any RemoteConfigRepository) {
        self.remoteConfigRepository = remoteConfigRepository
    }

    func execute() async throws -> StartupConfigLoadResult {
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

public func makeLoadStartupConfigUseCase(
    remoteConfigRepository: any RemoteConfigRepository
) -> any LoadStartupConfigUseCaseProtocol {
    LoadStartupConfigUseCase(remoteConfigRepository: remoteConfigRepository)
}
