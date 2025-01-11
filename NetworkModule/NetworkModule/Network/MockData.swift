import Foundation

enum FileExtensions: String {
    case json
}

struct MockData: Equatable {
    let fileName: String
    let extensions: FileExtensions
    let sendError: Bool
}
