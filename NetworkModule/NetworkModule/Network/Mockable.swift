import Foundation

protocol Mockable: AnyObject {
    var bundle: Bundle { get }
    
    func loadJSON<T: Decodable>(fileName: String, extensions: FileExtensions, type: T.Type) -> T
}

extension Mockable {
    var bundle: Bundle {
        return Bundle(for: type(of: self))
    }
    
    func loadJSON<T: Decodable>(fileName: String, extensions: FileExtensions = .json, type: T.Type) -> T {
        guard let fileUrl = bundle.url(forResource: fileName, withExtension: extensions.rawValue) else {
            fatalError("Not Exist \(fileName).\(extensions.rawValue)")
        }
        
        do {
            let data = try Data(contentsOf: fileUrl)
            let decodedObject = try JSONDecoder().decode(type, from: data)
            
            return decodedObject
            
        } catch {
            fatalError("Failed to decode loaded JSON")
        }
    }
}
