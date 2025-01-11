import Foundation

enum Config {
    enum Scheme: String {
        case http
        case https
    }
    
    enum Method: String {
        case get = "GET"
        case post = "POST"
        case delete  = "DELETE"
        case put = "PUT"
    }
    
    enum Task {
        case requestPlain
        case requestParameters(parameters: [String: Any])
    }
}

protocol ApiType {
    var baseUrl: String { get }
    var scheme: Config.Scheme { get }
    var method: Config.Method { get }
    var host: String { get }
    var path: String { get }
    var queryItems: [String: String]? { get }
    var body: [String: Any] { get }
    var headers: [String: String]? { get }
    var task: Config.Task { get }
    var mock: MockData? { get }
}
