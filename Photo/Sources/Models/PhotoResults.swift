import Foundation

public struct PhotoResults: Equatable, Hashable, Codable {
    public let results: [Photo]
    public let total: Int
    public let totalPages: Int
    
    enum CodingKeys: String, CodingKey {
        case results, total
        case totalPages = "total_pages"
    }
}

public struct Photo: Equatable, Hashable, Identifiable, Codable {
    public let id: String
    public let urls: URLS
    
    public var size: CGSize {
        CGSize(width: 128, height: 128)
    }
}

public struct URLS: Equatable, Hashable, Codable {
    public let regular: String
    public let small: String
}
