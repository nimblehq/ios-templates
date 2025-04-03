import Foundation

@discardableResult
func safeShell(_ command: String) throws -> String? {
    let task = Process()
    let pipe = Pipe()
    let errorPipe = Pipe()
    
    task.standardOutput = pipe
    task.standardError = errorPipe
    task.arguments = ["-c", command]
    task.executableURL = URL(fileURLWithPath: "/bin/zsh")
    task.standardInput = nil
    
    print("🔧 Executing command: \(command)")
    
    do {
        try task.run()
        
        let outputData = pipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        
        let output = String(data: outputData, encoding: .utf8)
        let error = String(data: errorData, encoding: .utf8)
        
        if let error = error, !error.isEmpty {
            print("⚠️ Command error output: \(error)")
        }
        
        task.waitUntilExit()
        
        if task.terminationStatus != 0 {
            throw NSError(
                domain: "SafeShell",
                code: Int(task.terminationStatus),
                userInfo: [
                    NSLocalizedDescriptionKey: "Command failed with exit code \(task.terminationStatus)",
                    "error": error ?? "Unknown error"
                ]
            )
        }
        
        return output
    } catch {
        print("❌ Command execution failed: \(error.localizedDescription)")
        throw error
    }
}
