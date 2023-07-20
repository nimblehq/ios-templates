struct SetUpDeliveryConstants {

    func perform() {
        print("Do you want to set up Constants values? (Can be edited later) [Y/n]: ")

        let arg = readLine() ?? "y"

        switch arg.lowercased() {
            case "y", "yes":
                do {
                    let error = try safeShell("open -a Xcode fastlane/Constants/Constant.swift")
                    guard let error = error, !error.isEmpty else { break }
                    print("Could not open Xcode. Make sure Xcode is installed and try again.\nRaw error: \(error)")
                } catch {
                    print("Error: \(error)")
                }
            default:
                print("✅  Completed. You can edit this file at 'fastlane/Constants/Constant.swift'.")
        }
    }
}
