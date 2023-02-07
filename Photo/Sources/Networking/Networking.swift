import Combine
import Foundation
import Models

public enum Error: LocalizedError {
    case noData
    case invalidStatusCode(Int)
    
    public var errorDescription: String? {
        switch self {
        case .noData:
            return "No data returned by response"
        case .invalidStatusCode(let code):
            return "Invalid status code: \(code)"
        }
    }
}

public class Networking {
    public static var urlSession: URLSession = {
        URLSession.shared
    }()
    
    public static let accessKey: String = "qxkNpAsHQfd9DQ2Ewk4qfbLBNPwRTbKSbKEB9gg6JwE"
    
    public static func makeRequest(_ request: URLRequest) -> AnyPublisher<Data, Failure> {
        return urlSession.dataTaskPublisher(for: request)
            .tryMap { data, response in
                if let response = response as? HTTPURLResponse {
                    if (200...299).contains(response.statusCode) {
                        return data
                    } else {
                        throw Error.invalidStatusCode(response.statusCode)
                    }
                }
                throw Error.noData
            }
            .mapError { error in Failure(error: error) }
            .eraseToAnyPublisher()
    }
}
