import Foundation

struct SetUpInterface {

    enum Interface: Titlable, CaseIterable {
        case swiftUI

        init?(_ name: String) {
            let name = name.lowercased()
            if name == "s" || name == "swiftui" || name.isEmpty {
                self = .swiftUI
            } else {
                return nil
            }
        }

        var folderName: String {
            return "SwiftUI"
        }

        var title: String { folderName }
    }

    private let fileManager = FileManager.default

    func perform(_ interface: Interface, _ projectName: String) throws {
        let swiftUIAppDirectory = "Tuist/Interfaces/SwiftUI/Sources/Application"
        try fileManager.rename(
            file: "\(swiftUIAppDirectory)/App.swift",
            to: "\(swiftUIAppDirectory)/\(projectName)App.swift"
        )

        try fileManager.moveFiles(in: "Tuist/Interfaces/SwiftUI/Sources", to: "\(projectName)/Sources")
        try fileManager.removeItems(in: "Tuist/Interfaces")
    }
}
