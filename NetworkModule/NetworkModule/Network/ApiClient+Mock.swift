import Foundation
import Combine

extension ApiClient {
    func stubAsyncRequest<T>(_ api: Api, responseModel: T.Type) async throws -> T where T : Decodable {
        return try await stubAsyncDelayRequest(api, responseModel: responseModel)
    }
    
    func stubAsyncDelayRequest<T>(_ api: Api, responseModel: T.Type, delayTime: TimeInterval = 0) async throws -> T where T : Decodable {
        guard let mock = api.mock else {
            throw NetworkError.unknownError("Not Exist MockData")
        }
        
        Task.delayed(byTimeInterval: delayTime) {
            print("Delay End")
        }
        
        if mock.sendError {
            throw NetworkError.requestError("asyncRequest Immediate Failed")
        } else {
            return loadJSON(fileName: mock.fileName, extensions: mock.extensions, type: responseModel.self)
        }
    }


    func stubCombineRequest<T>(_ api: Api, responseModel: T.Type) -> AnyPublisher<T, NetworkError> where T : Decodable {
        return stubCombineDelayRequest(api, responseModel: responseModel.self)
    }
    
    func stubCombineDelayRequest<T>(_ api: Api, responseModel: T.Type, delayTime: TimeInterval = 0) -> AnyPublisher<T, NetworkError> where T : Decodable {
        guard let mock = api.mock else {
            return Fail(error: NetworkError.unknownError("Not Exist MockData")).eraseToAnyPublisher()
        }
        
        if mock.sendError {
            return Fail(error: NetworkError.requestError("asyncRequest Immediate Failed"))
                .delay(for: .seconds(delayTime), scheduler: RunLoop.main)
                .eraseToAnyPublisher()
        } else {
            return Just(loadJSON(fileName: mock.fileName, extensions: mock.extensions, type: responseModel.self))
                .setFailureType(to: NetworkError.self)
                .delay(for: .seconds(delayTime), scheduler: RunLoop.main)
                .eraseToAnyPublisher()
        }
    }
    
}

