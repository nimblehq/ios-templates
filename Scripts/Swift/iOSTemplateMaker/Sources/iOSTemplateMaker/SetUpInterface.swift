import Foundation

struct SetUpInterface {

    enum Interface: Titlable, CaseIterable {

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

        var title: String { folderName }
    }

    private let fileManager = FileManager.default

    func perform(_ interface: Interface, _ projectName: String) throws {
        switch interface {
        case .swiftUI:
            let swiftUIAppDirectory = "tuist/Interfaces/SwiftUI/Sources/Application"
            try fileManager.rename(
                file: "\(swiftUIAppDirectory)/App.swift",
                to: "\(swiftUIAppDirectory)/\(projectName)App.swift"
            )
        case .uiKit: break
        }

        let folderName = interface.folderName

        try fileManager.moveFiles(in: "tuist/Interfaces/\(folderName)/Project", to: "")
        try fileManager.moveFiles(in: "tuist/Interfaces/\(folderName)/Sources", to: "\(projectName)/Sources")
        try fileManager.removeItems(in: "tuist/Interfaces")
    }
}
