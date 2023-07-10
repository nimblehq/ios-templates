import Foundation

extension FileManager {

    func replaceAllOccurrences(of original: String, to replacing: String) throws {
        try safeShell("LC_ALL=C find \(currentDirectoryPath) -type f -exec sed -i \"\" \"s/\(original)/\(replacing)/g\" {} +")
    }
}
