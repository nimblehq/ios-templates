import Foundation

extension FileManager {

  public func moveFiles(in directory: String, to destination: String) {
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
            toPath:"\(currentDirectory)/\(destination)/\(file)")                 
        } catch {                 
          print("Error \(error)")             
        }         
      }     
    }
  }
}
