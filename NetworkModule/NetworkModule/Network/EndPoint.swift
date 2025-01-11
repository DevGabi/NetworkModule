import Foundation

class EndPoint {
    let method: Config.Method
    let scheme: Config.Scheme
    let host: String
    let path: String
    let queryItems: [String: String]?
    let body: [String: Any]?
    let headers: [String: String]?
    let task: Config.Task
    let mock: MockData?
    
    init(method: Config.Method,
         scheme: Config.Scheme,
         host: String,
         path: String,
         queryItems: [String : String]? = nil,
         body: [String: Any]? = nil,
         headers: [String : String]? = nil,
         task: Config.Task,
         mock: MockData? = nil) {
        self.method = method
        self.scheme = scheme
        self.host = host
        self.path = path
        self.queryItems = queryItems
        self.body = body
        self.headers = headers
        self.task = task
        self.mock = mock
    }
    
    func asUrlRequest() throws -> URLRequest {
        var urlComponents = URLComponents()
        
        urlComponents.scheme = scheme.rawValue
        urlComponents.host = host
        urlComponents.path = path
        urlComponents.queryItems = queryItems?.asQueryItem()
        
        guard let url = urlComponents.url else {
            throw NetworkError.urlError(urlComponents)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.allHTTPHeaderFields = headers
        
        if let body {
            do {
                urlRequest.httpBody = try body.asData()
            } catch let error as NetworkError{
                throw error
            } catch {
                throw NetworkError.bodyEncodingError
            }
        }
        
        return URLRequest(url: url)
    }
}
