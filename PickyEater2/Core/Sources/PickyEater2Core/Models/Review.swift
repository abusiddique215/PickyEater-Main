import Foundation

public struct Review: Codable, Identifiable, Equatable {
    public let id: String
    public let rating: Double
    public let text: String
    public let timeCreated: Date
    public let user: User

    public init(id: String, rating: Double, text: String, timeCreated: Date, user: User) {
        self.id = id
        self.rating = rating
        self.text = text
        self.timeCreated = timeCreated
        self.user = user
    }

    public struct User: Codable, Equatable {
        public let id: String
        public let name: String
        public let imageUrl: String?

        public init(id: String, name: String, imageUrl: String?) {
            self.id = id
            self.name = name
            self.imageUrl = imageUrl
        }
    }
}
