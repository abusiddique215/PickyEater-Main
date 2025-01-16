import Foundation

public struct Review: Identifiable, Codable, Hashable {
    public let id: String
    public let rating: Double
    public let text: String
    public let timeCreated: Date
    public let user: User
    
    public init(
        id: String,
        rating: Double,
        text: String,
        timeCreated: Date,
        user: User
    ) {
        self.id = id
        self.rating = rating
        self.text = text
        self.timeCreated = timeCreated
        self.user = user
    }
} 