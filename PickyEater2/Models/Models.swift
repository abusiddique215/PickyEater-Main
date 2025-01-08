import Foundation

// MARK: - Yelp API Response Models

struct RestaurantSearchResponse: Codable {
    let businesses: [Restaurant]
    let total: Int
    let region: Region

    struct Region: Codable {
        let center: Center

        struct Center: Codable {
            let latitude: Double
            let longitude: Double
        }
    }
}

struct Restaurant: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let imageUrl: String
    let isClosed: Bool
    let url: String
    let reviewCount: Int
    let categories: [Category]
    let rating: Double
    let coordinates: Coordinates
    let photos: [String] // This will be populated from the business details endpoint
    let price: String?
    let location: Location
    let phone: String
    let displayPhone: String
    let distance: Double?

    enum CodingKeys: String, CodingKey {
        case id, name, url, categories, rating, coordinates, price, location, phone, distance
        case imageUrl = "image_url"
        case isClosed = "is_closed"
        case reviewCount = "review_count"
        case displayPhone = "display_phone"
        case photos
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        imageUrl = try container.decode(String.self, forKey: .imageUrl)
        isClosed = try container.decode(Bool.self, forKey: .isClosed)
        url = try container.decode(String.self, forKey: .url)
        reviewCount = try container.decode(Int.self, forKey: .reviewCount)
        categories = try container.decode([Category].self, forKey: .categories)
        rating = try container.decode(Double.self, forKey: .rating)
        coordinates = try container.decode(Coordinates.self, forKey: .coordinates)
        price = try container.decodeIfPresent(String.self, forKey: .price)
        location = try container.decode(Location.self, forKey: .location)
        phone = try container.decode(String.self, forKey: .phone)
        displayPhone = try container.decode(String.self, forKey: .displayPhone)
        distance = try container.decodeIfPresent(Double.self, forKey: .distance)

        // Set photos array to include at least the main image URL
        photos = [imageUrl]
    }

    static func == (lhs: Restaurant, rhs: Restaurant) -> Bool {
        lhs.id == rhs.id
    }
}

struct Category: Codable, Equatable {
    let alias: String
    let title: String
}

struct Coordinates: Codable, Equatable {
    let latitude: Double
    let longitude: Double
}

struct Location: Codable, Equatable {
    let address1: String
    let address2: String?
    let address3: String?
    let city: String
    let zipCode: String
    let country: String
    let state: String
    let displayAddress: [String]

    enum CodingKeys: String, CodingKey {
        case address1, address2, address3, city, country, state
        case zipCode = "zip_code"
        case displayAddress = "display_address"
    }
}
