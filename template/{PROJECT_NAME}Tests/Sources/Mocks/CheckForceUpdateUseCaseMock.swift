import Domain

struct CheckForceUpdateUseCaseMock: CheckForceUpdateUseCaseProtocol {

    let shouldForceUpdate: Bool

    func callAsFunction() async -> Bool {
        shouldForceUpdate
    }
}
