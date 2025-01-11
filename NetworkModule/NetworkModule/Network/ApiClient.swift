import Foundation
import Combine

protocol ApiClientType: AnyObject {
    associatedtype Api: ApiType
    
    func asyncRequest<T: Decodable>(_ api: Api, responseModel: T.Type) async throws -> T
    func combineRequest<T: Decodable>(_ api: Api, responseModel: T.Type) -> AnyPublisher<T, NetworkError>
}

final class ApiClient<Api: ApiType>: ApiClientType, Mockable {
    typealias EndPointClosure = (Api) -> EndPoint
    typealias StubClosure = (Api) -> StubBehavior
    
    var session: URLSession
    
    var endPointClosure: EndPointClosure
    var stubClosure: StubClosure
    
    init(session: URLSession,
         endPointClosure: @escaping EndPointClosure = ApiClient.endPointMapping,
         stubClosure: @escaping StubClosure = ApiClient.neverStub) {
        self.session = session
        self.endPointClosure = endPointClosure
        self.stubClosure = stubClosure
    }
    
    convenience init() {
        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        configuration.timeoutIntervalForRequest = 60
        configuration.timeoutIntervalForResource = 300
        
        let session = URLSession(configuration: configuration)
           
        self.init(session: session)
    }
    
    func asyncRequest<T>(_ api: Api, responseModel: T.Type) async throws -> T where T : Decodable {
        let endPoint = endPointClosure(api)
        let stubBehavior = stubClosure(api)
        
        switch stubBehavior {
        case .never:
            do {
                let (data, response) = try await session.data(for: endPoint.asUrlRequest())
                return try handleResponse(data: data, response: response)
            } catch {
                throw NetworkError.unknownError(error.localizedDescription)
            }
        case .immediate:
            return try await stubAsyncRequest(api, responseModel: responseModel.self)
        case .delay(let seconds):
            let value = try await stubAsyncDelayRequest(api, responseModel: responseModel.self, delayTime: seconds)
            return value
        }
    }
    
    func combineRequest<T>(_ api: Api, responseModel: T.Type) -> AnyPublisher<T, NetworkError> where T : Decodable {
        let endPoint = endPointClosure(api)
        let stubBehavior = stubClosure(api)
        
        switch stubBehavior {
        case .never:
            do {
                return session.dataTaskPublisher(for: try endPoint.asUrlRequest())
                    .tryMap {
                        try self.handleResponse(data: $0.data, response: $0.response)
                    }
                    .mapError {
                        $0 as? NetworkError ?? NetworkError.unknownError($0.localizedDescription)
                    }
                    .eraseToAnyPublisher()
            } catch let error as NetworkError {
                return AnyPublisher<T, NetworkError>(Fail(error: error))
            } catch {
                return AnyPublisher<T, NetworkError>(Fail(error: NetworkError.unknownError(error.localizedDescription)))
            }
        case .immediate:
            return stubCombineRequest(api, responseModel: responseModel.self)
        case .delay(let seconds):
            return stubCombineDelayRequest(api, responseModel: responseModel.self, delayTime: seconds)
        }
    }
}

extension ApiClient {
    private func handleResponse<T: Decodable>(data: Data, response: URLResponse) throws -> T {
        guard let response = response as? HTTPURLResponse else {
            throw NetworkError.invalidHttpResponse
        }
        
        switch response.statusCode {
        case 200...299:
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                throw NetworkError.decode(error)
            }
        default:
            throw NetworkError.serverError
        }
    }
}

extension ApiClient {
    class func endPointMapping(_ api: Api) -> EndPoint {
        EndPoint(method: api.method,
                 scheme: api.scheme,
                 host: api.host,
                 path: api.path,
                 queryItems: api.queryItems,
                 body: api.body,
                 headers: api.headers,
                 task: api.task,
                 mock: api.mock)
    }
}
