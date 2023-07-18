
struct SetUpInterface {

    enum Interface {

        case swiftUI, uiKit

        init?(_ name: String) {
            switch name.lowercased() {
            case "s", "swiftui":
                self = .swiftUI
            case "u", "uikit":
                self = .uiKit
            default: return nil
            }
        }

        var folderName: String {
            switch self {
                case .swiftUI: return "SwiftUI"
                case .uiKit: return "UIKit"
            }
        }
    }

    func perform(_ interface: Interface, _ projectName: String) {
        let fileManager = FileManager.default

        switch interface {
        case .swiftUI:
            print("=> 🦅 Setting up SwiftUI")
            let swiftUIAppDirectory = "tuist/Interfaces/SwiftUI/Sources/Application"
            fileManager.rename(
                file: "\(swiftUIAppDirectory)/App.swift",
                to: "\(swiftUIAppDirectory)/\(projectName)App.swift"
            )
        case .uiKit:
            print("=> 🦉 Setting up UIKit")
        }

        let folderName = interface.folderName

        fileManager.moveFiles(in: "tuist/Interfaces/\(folderName)/Project", to: "")
        fileManager.moveFiles(in: "tuist/Interfaces/\(folderName)/Sources", to: "TemplateApp/Sources")
        fileManager.removeItems(in: "tuist/Interfaces")
    }
}
