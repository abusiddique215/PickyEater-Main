import Foundation

public struct Review: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let rating: Double
    public let text: String
    public let timeCreated: Date
    public let user: ReviewUser
    
    public struct ReviewUser: Codable, Hashable, Sendable {
        public let id: String
        public let name: String
        
        public init(id: String, name: String) {
            self.id = id
            self.name = name
        }
        
        enum CodingKeys: String, CodingKey {
            case id
            case name
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case rating
        case text
        case timeCreated = "time_created"
        case user
    }
    
    public init(
        id: String,
        rating: Double,
        text: String,
        timeCreated: Date,
        user: ReviewUser
    ) {
        self.id = id
        self.rating = rating
        self.text = text
        self.timeCreated = timeCreated
        self.user = user
    }
} 