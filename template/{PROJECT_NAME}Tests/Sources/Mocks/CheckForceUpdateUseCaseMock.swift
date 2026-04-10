import Domain

struct CheckForceUpdateUseCaseMock: CheckForceUpdateUseCaseProtocol {

    let shouldForceUpdate: Bool

    func execute() async -> Bool {
        shouldForceUpdate
    }
}
