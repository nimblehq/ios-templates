import Testing

@testable import Domain

@Suite("LoadStartupConfigUseCase")
struct LoadStartupConfigUseCaseTests {

    @Test("returns refreshed when startup config refresh succeeds")
    func callAsFunctionReturnsRefreshedWhenStartupConfigRefreshSucceeds() async {
        let repository = StubRemoteConfigRepository()
        let useCase = LoadStartupConfigUseCase(remoteConfigRepository: repository)

        let result = try? await useCase.execute()

        #expect(result == .refreshed)
        #expect(await repository.refreshCallCount() == 1)
    }

    @Test("returns local defaults when startup config refresh fails")
    func callAsFunctionReturnsLocalDefaultsWhenStartupConfigRefreshFails() async {
        let repository = StubRemoteConfigRepository(shouldFailRefresh: true)
        let useCase = LoadStartupConfigUseCase(remoteConfigRepository: repository)

        let result = try? await useCase.execute()

        #expect(result == .usedLocalDefaults)
        #expect(await repository.refreshCallCount() == 1)
    }
}

private actor StubRemoteConfigRepository: RemoteConfigRepository {

    enum SampleError: Error {

        case failed
    }

    private let shouldFailRefresh: Bool
    private var refreshCalls = 0

    init(shouldFailRefresh: Bool = false) {
        self.shouldFailRefresh = shouldFailRefresh
    }

    func refresh() async throws {
        refreshCalls += 1

        if shouldFailRefresh {
            throw SampleError.failed
        }
    }

    func value<Value: RemoteConfigValueConvertible>(for key: RemoteConfigKey<Value>) async -> Value {
        key.defaultValue
    }

    func refreshCallCount() -> Int {
        refreshCalls
    }
}
