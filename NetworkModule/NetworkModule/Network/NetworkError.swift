import Foundation

enum NetworkError: Error {
    case invalidHttpResponse
    case urlError(URLComponents)
    case bodyEncodingError
    case requestConvertError(URLComponents)
    case unknownError(String)
    case serverError
    case decode(Error)
    case requestError(String)
}
