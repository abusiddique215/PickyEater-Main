import Foundation
import CoreLocation

struct Restaurant: Identifiable, Codable, ModelIdentifiable {
    let id: String
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    let phoneNumber: String?
    let websiteURL: URL?
    let rating: Double
    let reviewCount: Int
    let priceRange: PriceRange?
    let cuisineTypes: [CuisineType]
    let dietaryOptions: [DietaryRestriction]
    let imageURLs: [URL]
    let hours: [String: String]
    let isOpen: Bool
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var formattedRating: String {
        String(format: "%.1f", rating)
    }
    
    var formattedReviewCount: String {
        "\(reviewCount) reviews"
    }
} 