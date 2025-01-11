import Foundation

extension Dictionary where Key == String, Value == String {
    func asQueryItem() -> [URLQueryItem] {
        return map {
            .init(name: $0.key, value: $0.value)
        }
    }
}

extension Dictionary where Key == String, Value == Any {
    func asData() throws -> Data? {
        do {
            return try JSONSerialization.data(withJSONObject: self, options: [])
        } catch {
            throw NetworkError.bodyEncodingError
        }
    }
}
