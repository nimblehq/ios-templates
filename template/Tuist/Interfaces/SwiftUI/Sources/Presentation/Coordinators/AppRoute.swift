enum AppRoute: Hashable, Identifiable {

    case settings

    var id: String {
        switch self {
        case .settings:
            return "settings"
        }
    }
}
