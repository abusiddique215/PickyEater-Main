import Foundation

public struct Category: Codable, Hashable, Sendable {
    public let alias: String
    public let title: String
    
    public init(alias: String, title: String) {
        self.alias = alias
        self.title = title
    }
    
    enum CodingKeys: String, CodingKey {
        case alias
        case title
    }
} 