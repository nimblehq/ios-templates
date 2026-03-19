struct SetUpDeliveryConstants {

    func perform(setupConstants: Bool? = nil) throws {
        let result: ConfirmResult
        if let setupConstants {
            result = setupConstants ? .yes : .no
        } else {
            result = confirm("Do you want to set up Constants values?")
        }
        switch result {
        case .yes:
            try safeShell("open -a Xcode fastlane/Constants/Constant.swift")
        case .no: break
        }
    }
}
