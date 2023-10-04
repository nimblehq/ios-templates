import Foundation

struct SetUpInterface {

    enum Interface {

        case swiftUI, uiKit

        init?(_ name: String) {
            let name = name.lowercased()
            if name == "s" || name == "swiftui" {
                self = .swiftUI
            } else if name == "u" || name == "uikit" {
                self = .uiKit
            } else {
                return nil
            }
        }

        var folderName: String {
            switch self {
                case .swiftUI: return "SwiftUI"
                case .uiKit: return "UIKit"
            }
        }
    }

    private let fileManager = FileManager.default

    func perform(_ interface: Interface, _ projectName: String) {
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
        fileManager.moveFiles(in: "tuist/Interfaces/\(folderName)/Sources", to: "\(projectName)/Sources")
        fileManager.removeItems(in: "tuist/Interfaces")
    }
}
