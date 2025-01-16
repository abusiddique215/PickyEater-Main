import Foundation

public struct Review: Identifiable, Codable, Hashable {
    public let id: String
    public let rating: Int
    public let text: String
    public let timeCreated: String
    public let user: ReviewUser
    
    public struct ReviewUser: Codable, Hashable {
        public let id: String
        public let name: String
        
        public init(id: String, name: String) {
            self.id = id
            self.name = name
        }
    }
    
    public init(id: String, rating: Int, text: String, timeCreated: String, user: ReviewUser) {
        self.id = id
        self.rating = rating
        self.text = text
        self.timeCreated = timeCreated
        self.user = user
    }
} 