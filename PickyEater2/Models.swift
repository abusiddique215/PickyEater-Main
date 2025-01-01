import Foundation

struct RestaurantSearchResponse: Codable {
    let businesses: [Restaurant]
    let total: Int
}

struct Restaurant: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let location: Location
    let categories: [Category]
    let photos: [String]
    let rating: Double
    let reviewCount: Int
    let price: String?
    let displayPhone: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, location, categories, rating, price
        case reviewCount = "review_count"
        case displayPhone = "display_phone"
        case photos = "image_url"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        location = try container.decode(Location.self, forKey: .location)
        categories = try container.decode([Category].self, forKey: .categories)
        rating = try container.decode(Double.self, forKey: .rating)
        reviewCount = try container.decode(Int.self, forKey: .reviewCount)
        price = try container.decodeIfPresent(String.self, forKey: .price)
        displayPhone = try container.decodeIfPresent(String.self, forKey: .displayPhone)
        
        // Handle single image_url as array
        if let imageUrl = try container.decodeIfPresent(String.self, forKey: .photos) {
            photos = [imageUrl]
        } else {
            photos = []
        }
    }
    
    static func == (lhs: Restaurant, rhs: Restaurant) -> Bool {
        lhs.id == rhs.id
    }
}

struct Location: Codable, Equatable {
    let address1: String
    let city: String
    let state: String
    let country: String
    let latitude: Double
    let longitude: Double
    let zipCode: String
    
    enum CodingKeys: String, CodingKey {
        case address1, city, state, country
        case latitude = "lat"
        case longitude = "lng"
        case zipCode = "zip_code"
    }
}

struct Category: Codable, Equatable {
    let alias: String
    let title: String
}