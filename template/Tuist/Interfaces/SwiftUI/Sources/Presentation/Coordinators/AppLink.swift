import Foundation

struct AppLink: Equatable {

    enum PresentationStyle: Equatable {

        case push
        case fullScreen
    }

    let route: AppRoute
    let presentationStyle: PresentationStyle

    init(route: AppRoute, presentationStyle: PresentationStyle) {
        self.route = route
        self.presentationStyle = presentationStyle
    }

    init?(url: URL) {
        self.init(path: Self.normalizedPath(from: url))
    }

    init?(path: String) {
        switch path.normalizedAppLinkPath {
        case "/settings":
            route = .settings
            presentationStyle = .push
        case "/settings/full-screen":
            route = .settings
            presentationStyle = .fullScreen
        default:
            return nil
        }
    }
}

private extension AppLink {

    static func normalizedPath(from url: URL) -> String {
        if url.scheme == "http" || url.scheme == "https" {
            return url.path
        }

        return [url.host, url.path]
            .compactMap { $0 }
            .joined()
    }
}

private extension String {

    var normalizedAppLinkPath: String {
        let path = trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return "/\(path)"
    }
}
