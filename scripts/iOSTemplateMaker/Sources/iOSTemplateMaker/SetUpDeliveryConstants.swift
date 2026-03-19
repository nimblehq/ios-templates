struct SetUpDeliveryConstants {

    func perform() throws {
        let result = confirm("Do you want to set up Constants values?")
        switch result {
        case .yes:
            try safeShell("open -a Xcode fastlane/Constants/Constant.swift")
        case .no: break
        }
    }
}
