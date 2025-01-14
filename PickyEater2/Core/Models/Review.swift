import Foundation

struct Review: Identifiable, Codable, ModelIdentifiable {
    let id: String
    let restaurantId: String
    let userId: String
    let rating: Double
    let text: String
    let date: Date
    let images: [URL]?
    let likes: Int
    let isVerified: Bool
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    var formattedRating: String {
        String(format: "%.1f", rating)
    }
} 