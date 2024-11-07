import Foundation

extension FileManager {

    func moveFiles(in directory: String, to destination: String) throws {
        let currentDirectory = currentDirectoryPath
        let files = try? contentsOfDirectory(
            atPath: "\(currentDirectory)/\(directory)"
        )
        if let files = files {
            for file in files {
                guard file != ".DS_Store" else { continue }
                try moveItem(
                    atPath: "\(currentDirectory)/\(directory)/\(file)",
                    toPath:"\(currentDirectory)/\(destination)/\(file)"
                )
            }
        }
    }

    func rename(file: String, to destination: String) throws {
        let currentDirectory = currentDirectoryPath
        try moveItem(
            atPath: "\(currentDirectory)/\(file)",
            toPath:"\(currentDirectory)/\(destination)"
        )
    }

    func copy(file: String, to destination: String) throws {
        let currentDirectory = currentDirectoryPath
        try copyItem(
            atPath: "\(currentDirectory)/\(file)",
            toPath:"\(currentDirectory)/\(destination)"
        )
    }

    func createDirectory(path: String) throws {
        let currentDirectory = currentDirectoryPath
        try createDirectory(atPath: "\(currentDirectory)/\(path)", withIntermediateDirectories: true, attributes: nil)
    }

    func createFile(name: String, at directory: String) throws {
        let currentDirectory = currentDirectoryPath
        try createDirectory(path: directory)
        createFile(atPath: "\(currentDirectory)\(directory)\(name)", contents: nil)
    }

    func removeItems(in directory: String) throws {
        let currentDirectory = currentDirectoryPath
        try removeItem(atPath: "\(currentDirectory)/\(directory)")
    }

    func replaceAllOccurrences(of original: String, to replacing: String) {
        let swiftScriptBuildDirectory = "Scripts/Swift/iOSTemplateMaker/.build".lowercased()
        let pngImage = ".png"
        let files = try? allFiles(in: currentDirectoryPath, skips: [swiftScriptBuildDirectory, pngImage])
        guard let files else { return print("Cannot find any files in current directory") }
        for file in files {
            do {
                guard let text = try? String(contentsOf: file, encoding: .utf8) else {
                    continue
                }

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
