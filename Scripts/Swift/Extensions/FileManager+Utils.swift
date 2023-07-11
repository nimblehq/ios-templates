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

    func removeItems(in directory: String) {
        let currentDirectory = currentDirectoryPath
        do {
            try removeItem(atPath: "\(currentDirectory)/\(directory)")
        } catch {
            print("Error \(error)")
        }
    }

    func replaceAllOccurrences(of original: String, to replacing: String) throws {
        let files = try allFiles(in: currentDirectoryPath)
        for file in files {
            do {
                let text = try String(contentsOf: file, encoding: .utf8)
                let modifiedText = text.replacingOccurrences(of: original, with: replacing)
                try modifiedText.write(to: file, atomically: true, encoding: .utf8)
            }
            catch {
                print(error)
            }
        }
    }

    private func allFiles(in directory: String) throws -> [URL] {
        let url = URL(fileURLWithPath: directory)
        var files = [URL]()
        if let enumerator = enumerator(at: url, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
            for case let fileURL as URL in enumerator {
                do {
                    let fileAttributes = try fileURL.resourceValues(forKeys:[.isRegularFileKey])
                    guard fileAttributes.isRegularFile ?? false else { continue }
                    files.append(fileURL)
                }
            }
        }
        return files
    }
}
