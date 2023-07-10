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
}
