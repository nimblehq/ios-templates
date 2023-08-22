import Foundation

extension Optional {

    func unwrappedOr(_ defaultValue: Wrapped) -> Wrapped {
        switch self {
        case .none:
            return defaultValue
        case let .some(value):
            return value
        }
    }
}

extension Optional where Wrapped == String {

    var string: String { unwrappedOr("") }
}
