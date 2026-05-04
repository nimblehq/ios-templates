import Testing

@testable import {PROJECT_NAME}

@MainActor
@Suite("AppRouter")
struct AppRouterTests {

    @Test("pushes routes onto the navigation path")
    func pushesRoutesOntoTheNavigationPath() {
        let router = AppRouter()

        router.push(.settings)

        #expect(router.path == [.settings])
    }

    @Test("pops the last route from the navigation path")
    func popsTheLastRouteFromTheNavigationPath() {
        let router = AppRouter()
        router.push(.settings)

        router.pop()

        #expect(router.path.isEmpty)
    }

    @Test("clears all routes from the navigation path")
    func clearsAllRoutesFromTheNavigationPath() {
        let router = AppRouter()
        router.push(.settings)
        router.push(.settings)

        router.popToRoot()

        #expect(router.path.isEmpty)
    }
}
