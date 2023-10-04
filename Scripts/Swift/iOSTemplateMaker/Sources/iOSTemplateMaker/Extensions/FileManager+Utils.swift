import Foundation

extension FileManager {

    func moveFiles(in directory: String, to destination: String) {
        let currentDirectory = currentDirectoryPath
        let files = try? contentsOfDirectory(
            atPath: "\(currentDirectory)/\(directory)"
        )
        if let files = files {
            for file in files {
                guard file != ".DS_Store" else { continue }
                do {
                    try moveItem(
                        atPath: "\(currentDirectory)/\(directory)/\(file)",
                        toPath:"\(currentDirectory)/\(destination)/\(file)"
                    )
                } catch {
                    print("Error \(error)")
                }
            }
        }
    }

    func rename(file: String, to destination: String) {
        let currentDirectory = currentDirectoryPath
        do {
            try moveItem(
                atPath: "\(currentDirectory)/\(file)",
                toPath:"\(currentDirectory)/\(destination)"
            )
        } catch {
            print("Error \(error)")
        }
    }

    func copy(file: String, to destination: String) {
        let currentDirectory = currentDirectoryPath
        do {
            try copyItem(
                atPath: "\(currentDirectory)/\(file)",
                toPath:"\(currentDirectory)/\(destination)"
            )
        } catch {
            print("Error \(error)")
        }
    }

    func createDirectory(path: String) {
        let currentDirectory = currentDirectoryPath
        do {
            try createDirectory(atPath: "\(currentDirectory)/\(path)", withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error \(error)")
        }
    }

    func createFile(name: String, at directory: String) {
        let currentDirectory = currentDirectoryPath
        createDirectory(path: directory)
        createFile(atPath: "\(currentDirectory)\(directory)\(name)", contents: nil)
    }

    func removeItems(in directory: String) {
        let currentDirectory = currentDirectoryPath
        do {
            try removeItem(atPath: "\(currentDirectory)/\(directory)")
        } catch {
            print("Error \(error)")
        }
    }

    func replaceAllOccurrences(of original: String, to replacing: String) {
        let swiftScriptBuildDirectory = "Scripts/Swift/iOSTemplateMaker/.build".lowercased()
        let pngImage = ".png"
        let files = try? allFiles(in: currentDirectoryPath, skips: [swiftScriptBuildDirectory, pngImage])
        guard let files else { return print("Cannot find any files in current directory") }
        for file in files {
            do {
                let text = try String(contentsOf: file, encoding: .utf8)
                let modifiedText = text.replacingOccurrences(of: original, with: replacing)
                try modifiedText.write(to: file, atomically: true, encoding: .utf8)
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    private func allFiles(in directory: String, skips: [String] = []) throws -> [URL] {
        let url = URL(fileURLWithPath: directory)
        var files = [URL]()
        if let enumerator = enumerator(
            at: url, 
            includingPropertiesForKeys: [.isRegularFileKey], 
            options: [.skipsPackageDescendants]
        ) {
            let hiddenFolderRegex = "\(directory.replacingOccurrences(of: "/", with: "\\/"))\\/\\..*\\/"
            for case let fileURL as URL in enumerator {
                guard !(fileURL.relativePath ~= hiddenFolderRegex) else { continue }
                guard !(skips.contains(where: { fileURL.relativePath.lowercased().contains($0) })) else { continue }
                let fileAttributes = try? fileURL.resourceValues(forKeys:[.isRegularFileKey])
                guard fileAttributes?.isRegularFile ?? false else { continue }
                files.append(fileURL)
            }
        }
        return files
    }
}
