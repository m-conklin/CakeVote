import Combine
import Foundation
import Models
import Networking

public struct ImageAPI {
    public init() {}
}

extension ImageAPI {
    public static let noop = ImageAPI()
}

extension ImageAPI {
    public func searchPhotos(query: String, page: Int = 1, perPage: Int = 30, orientation: PhotoOrientation = .landscape) -> AnyPublisher<PhotoResults, Failure> {
        return queryUnsplash(query: query, page: page, perPage: perPage, orientation: orientation)
    }
    
    private func queryUnsplash(query: String,  page: Int = 1, perPage: Int = 30, orientation: PhotoOrientation = .landscape)  -> AnyPublisher<PhotoResults, Failure> {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.unsplash.com"
        components.path = "/search/photos"
        components.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(perPage)"),
        ]
        
        if orientation != .any {
            components.queryItems?.append(URLQueryItem(name: "orientation", value: orientation.rawValue))
        }
        
        let url = components.url!
        
        var request = URLRequest(url: url)
        request.setValue("Client-ID \(Networking.accessKey)", forHTTPHeaderField: "Authorization")
        
        return Networking.makeRequest(request)
            .decode(type: PhotoResults.self, decoder: JSONDecoder())
            .mapError { error in Failure(error: error)}
            .eraseToAnyPublisher()
    }
}
