import Foundation
import Testing

@testable import {PROJECT_NAME}

@MainActor
@Suite("AppRouter")
struct AppRouterTests {

    @Test("pushes routes onto the navigation path")
    func pushesRoutesOntoTheNavigationPath() {
        let router = AppRouter()

        router.push(.settings)

        #expect(router.routes == [.settings])
    }

    @Test("pops the last route from the navigation path")
    func popsTheLastRouteFromTheNavigationPath() {
        let router = AppRouter()
        router.push(.settings)

        router.pop()

        #expect(router.routes.isEmpty)
    }

    @Test("clears all routes from the navigation path")
    func clearsAllRoutesFromTheNavigationPath() {
        let router = AppRouter()
        router.push(.settings)
        router.push(.settings)

        router.popToRoot()

        #expect(router.routes.isEmpty)
    }

    @Test("opens pushed app links from URLs")
    func opensPushedAppLinksFromURLs() throws {
        let router = AppRouter()
        let url = try #require(URL(string: "https://example.com/settings"))

        let handled = router.open(url)

        #expect(handled)
        #expect(router.routes == [.settings])
        #expect(router.fullScreenRoute == nil)
    }

    @Test("opens full-screen app links from URLs")
    func opensFullScreenAppLinksFromURLs() throws {
        let router = AppRouter()
        let url = try #require(URL(string: "https://example.com/settings/full-screen"))

        let handled = router.open(url)

        #expect(handled)
        #expect(router.routes.isEmpty)
        #expect(router.fullScreenRoute == .settings)
    }

    @Test("returns false when URLs are not supported")
    func returnsFalseWhenURLsAreNotSupported() throws {
        let router = AppRouter()
        let url = try #require(URL(string: "https://example.com/unsupported"))

        let handled = router.open(url)

        #expect(!handled)
        #expect(router.routes.isEmpty)
        #expect(router.fullScreenRoute == nil)
    }
}
