import Domain
import FactoryKit
import Foundation
import Model
import Nimble
import Quick

@testable import {PROJECT_NAME}

final class LandingViewModelSpec: QuickSpec {

    override class func spec() {
        describe("LandingViewModel") {
            it("shows the signed-out flow when no active session exists") {
                await Self.withSUT { _, _, viewModel in
                    await viewModel.restoreSessionIfNeeded()

                    expect(viewModel.state).to(equal(.signedOut))
                    expect(viewModel.startupConfigLoadResult).to(equal(.refreshed))
                }
            }

            it("shows the signed-in flow when an active session exists") {
                await Self.withSUT { sessionRepository, _, viewModel in
                    await sessionRepository.setHasActiveSession(true)

                    await viewModel.restoreSessionIfNeeded()

                    expect(viewModel.state).to(equal(.signedIn))
                    expect(viewModel.startupConfigLoadResult).to(equal(.refreshed))
                }
            }

            it("falls back to local defaults before showing the signed-out flow") {
                await Self.withSUT(startupConfigLoadResult: .usedLocalDefaults) { _, loader, viewModel in
                    await viewModel.restoreSessionIfNeeded()

                    expect(viewModel.state).to(equal(.signedOut))
                    expect(viewModel.startupConfigLoadResult).to(equal(.usedLocalDefaults))
                    expect(await loader.executeCallCount()).to(equal(1))
                }
            }

            it("loads startup config only once") {
                await Self.withSUT { _, loader, viewModel in
                    await viewModel.restoreSessionIfNeeded()
                    await viewModel.restoreSessionIfNeeded()

                    expect(await loader.executeCallCount()).to(equal(1))
                }
            }

            it("activates a demo session and shows the signed-in flow") {
                await Self.withSUT { _, _, viewModel in
                    await viewModel.continueWithDemoSession()

                    expect(viewModel.state).to(equal(.signedIn))
                }
            }

            it("keeps showing the signed-out flow when activating demo session fails") {
                await Self.withSUT { sessionRepository, _, viewModel in
                    await sessionRepository.setShouldFailActivation(true)

                    await viewModel.continueWithDemoSession()

                    expect(viewModel.state).to(equal(.signedOut))
                }
            }

            it("clears the session and shows the signed-out flow") {
                await Self.withSUT { _, _, viewModel in
                    await viewModel.continueWithDemoSession()

                    await viewModel.signOut()

                    expect(viewModel.state).to(equal(.signedOut))
                }
            }

            it("keeps showing the signed-in flow when clearing session fails") {
                await Self.withSUT { sessionRepository, _, viewModel in
                    await viewModel.continueWithDemoSession()
                    await sessionRepository.setShouldFailClearSession(true)

                    await viewModel.signOut()

                    expect(viewModel.state).to(equal(.signedIn))
                }
            }
        }
    }

    @MainActor
    private static func withSUT(
        startupConfigLoadResult: StartupConfigLoadResult = .refreshed,
        _ test: @MainActor (SessionRepositoryMock, StartupConfigLoaderMock, LandingViewModel) async -> Void
    ) async {
        Container.shared.reset()

        let sessionRepository = SessionRepositoryMock()
        let startupConfigLoader = StartupConfigLoaderMock(result: startupConfigLoadResult)
        Container.shared.loadStartupConfigUseCase.register { startupConfigLoader }
        Container.shared.sessionRepository.register { sessionRepository }

        let viewModel = LandingViewModel()
        defer {
            Container.shared.reset()
        }

        await test(sessionRepository, startupConfigLoader, viewModel)
    }
}

private actor SessionRepositoryMock: SessionRepositoryProtocol {

    enum SampleError: Error {

        case failed
    }

    private(set) var hasSession = false
    private(set) var shouldFailActivation = false
    private(set) var shouldFailClearSession = false
    private var tokenSet: (any TokenSetProtocol)?

    func hasActiveSession() -> Bool {
        hasSession
    }

    func currentTokenSet() -> (any TokenSetProtocol)? {
        tokenSet
    }

    func save(tokenSet: any TokenSetProtocol) throws {
        if shouldFailActivation {
            throw SampleError.failed
        }
        self.tokenSet = tokenSet
        hasSession = true
    }

    func clearSession() throws {
        if shouldFailClearSession {
            throw SampleError.failed
        }
        tokenSet = nil
        hasSession = false
    }

    func setHasActiveSession(_ hasSession: Bool) {
        self.hasSession = hasSession
    }

    func setShouldFailActivation(_ shouldFailActivation: Bool) {
        self.shouldFailActivation = shouldFailActivation
    }

    func setShouldFailClearSession(_ shouldFailClearSession: Bool) {
        self.shouldFailClearSession = shouldFailClearSession
    }
}

private actor StartupConfigLoaderMock: LoadStartupConfigUseCaseProtocol {

    private let result: StartupConfigLoadResult
    private var callCount = 0

    init(result: StartupConfigLoadResult) {
        self.result = result
    }

    func execute() async throws -> StartupConfigLoadResult {
        callCount += 1
        return result
    }

    func executeCallCount() -> Int {
        callCount
    }
}
