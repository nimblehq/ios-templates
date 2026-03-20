struct SetUpDeliveryConstants {

    func perform() throws {
        let result = confirm("Do you want to set up delivery constants?")
        switch result {
        case .yes:
            try safeShell("open -a Xcode fastlane/Constants/Constant.swift .asc/export-options-app-store.plist")
        case .no: break
        }
    }
}
