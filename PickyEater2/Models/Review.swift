import Foundation

struct Review: Identifiable, Codable, Equatable {
    let id: String
    let rating: Double
    let userName: String
    let userImageUrl: String?
    let text: String
    let timeCreated: Date
    let url: String

    static func == (lhs: Review, rhs: Review) -> Bool {
        lhs.id == rhs.id
    }

    static var preview: Review {
        Review(
            id: "1",
            rating: 4.5,
            userName: "John D.",
            userImageUrl: "https://example.com/user.jpg",
            text: "Great food and atmosphere! The service was excellent and the prices were reasonable. Would definitely come back again.",
            timeCreated: Date(),
            url: "https://www.yelp.com/review/1"
        )
    }
}
