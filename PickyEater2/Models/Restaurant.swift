import Foundation
import CoreLocation

struct Restaurant: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let imageUrl: String
    let rating: Double
    let reviewCount: Int
    let priceRange: PriceRange
    let categories: [String]
    let address: String
    let coordinates: CLLocationCoordinate2D
    let phone: String
    let distance: Double // in meters
    let isOpen: Bool
    let hours: [OpeningHours]
    
    struct OpeningHours: Codable, Equatable {
        let day: Int // 0 = Sunday, 6 = Saturday
        let start: String // "0800"
        let end: String // "2200"
        let isOvernight: Bool
    }
}

// MARK: - CLLocationCoordinate2D Codable
extension CLLocationCoordinate2D: Codable {
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        self.init(latitude: latitude, longitude: longitude)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
}

// MARK: - Restaurant Equatable
extension Restaurant {
    static func == (lhs: Restaurant, rhs: Restaurant) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Preview Helper
extension Restaurant {
    static var preview: Restaurant {
        Restaurant(
            id: "1",
            name: "Sample Restaurant",
            imageUrl: "https://example.com/image.jpg",
            rating: 4.5,
            reviewCount: 123,
            priceRange: .medium,
            categories: ["Italian", "Pizza", "Pasta"],
            address: "123 Main St, San Francisco, CA 94105",
            coordinates: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            phone: "(415) 555-0123",
            distance: 1200,
            isOpen: true,
            hours: [
                OpeningHours(day: 0, start: "1100", end: "2200", isOvernight: false),
                OpeningHours(day: 1, start: "1100", end: "2200", isOvernight: false),
                OpeningHours(day: 2, start: "1100", end: "2200", isOvernight: false),
                OpeningHours(day: 3, start: "1100", end: "2200", isOvernight: false),
                OpeningHours(day: 4, start: "1100", end: "2300", isOvernight: false),
                OpeningHours(day: 5, start: "1100", end: "2300", isOvernight: false),
                OpeningHours(day: 6, start: "1100", end: "2200", isOvernight: false)
            ]
        )
    }
} 