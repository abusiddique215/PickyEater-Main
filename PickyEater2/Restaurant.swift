import Foundation

struct Restaurant: Identifiable, Codable {
    let id: String
    let name: String
    let rating: Double
    let price: String?
    let photos: [String]?
    let location: Location
    let coordinates: Coordinates
    let categories: [Category]
    let isClosed: Bool
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case rating
        case price
        case photos = "photos"
        case location
        case coordinates
        case categories
        case isClosed = "is_closed"
    }
    
    struct Location: Codable {
        let address1: String
        let city: String
        let state: String
        let zipCode: String
        let country: String
        
        private enum CodingKeys: String, CodingKey {
            case address1
            case city
            case state
            case zipCode = "zip_code"
            case country
        }
    }
    
    struct Coordinates: Codable {
        let latitude: Double
        let longitude: Double
    }
    
    struct Category: Codable {
        let alias: String
        let title: String
    }
}

// MARK: - Sample Data
extension Restaurant {
    static let sample = Restaurant(
        id: "sample-id",
        name: "Sample Restaurant",
        rating: 4.5,
        price: "$$",
        photos: ["https://sample.com/photo.jpg"],
        location: Location(
            address1: "123 Main St",
            city: "San Francisco",
            state: "CA",
            zipCode: "94105",
            country: "US"
        ),
        coordinates: Coordinates(
            latitude: 37.7749,
            longitude: -122.4194
        ),
        categories: [
            Category(alias: "american", title: "American"),
            Category(alias: "burgers", title: "Burgers")
        ],
        isClosed: false
    )
} 