import Foundation
import Testing

@testable import {PROJECT_NAME}

@Suite("AppLink")
struct AppLinkTests {

    @Test("parses a universal link settings path as a pushed settings route")
    func parsesUniversalLinkSettingsPathAsAPushedSettingsRoute() throws {
        let url = try #require(URL(string: "https://example.com/settings"))

        let appLink = AppLink(url: url)

        #expect(appLink == AppLink(route: .settings, presentationStyle: .push))
    }

    @Test("parses a custom scheme settings path as a pushed settings route")
    func parsesCustomSchemeSettingsPathAsAPushedSettingsRoute() throws {
        let url = try #require(URL(string: "{BUNDLE_ID_STAGING}://settings"))

        let appLink = AppLink(url: url)

        #expect(appLink == AppLink(route: .settings, presentationStyle: .push))
    }

    @Test("parses a full-screen settings path")
    func parsesAFullScreenSettingsPath() throws {
        let url = try #require(URL(string: "https://example.com/settings/full-screen"))

        let appLink = AppLink(url: url)

        #expect(appLink == AppLink(route: .settings, presentationStyle: .fullScreen))
    }

    @Test("ignores unsupported paths")
    func ignoresUnsupportedPaths() throws {
        let url = try #require(URL(string: "https://example.com/unsupported"))

        let appLink = AppLink(url: url)

        #expect(appLink == nil)
    }
}
