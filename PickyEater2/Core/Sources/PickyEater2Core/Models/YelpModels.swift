import Foundation

// MARK: - Yelp Business Model
struct YelpBusiness: Codable {
    let id: String
    let name: String
    let distance: Double?
    let price: String?
    let rating: Double
    let reviewCount: Int
    let categories: [YelpCategory]
    let imageUrl: String?
    let location: YelpLocation
    let coordinates: YelpCoordinates
    let phone: String?
    let hours: [YelpHours]?
    
    enum CodingKeys: String, CodingKey {
        case id, name, distance, price, rating
        case reviewCount = "review_count"
        case categories
        case imageUrl = "image_url"
        case location, coordinates, phone, hours
    }
}

// MARK: - Yelp Category Model
struct YelpCategory: Codable {
    let alias: String
    let title: String
}

// MARK: - Yelp Location Model
struct YelpLocation: Codable {
    let address1: String?
    let address2: String?
    let address3: String?
    let city: String
    let state: String
    let zipCode: String
    let country: String
    
    var formattedAddress: String {
        var components = [String]()
        if let address1 = address1 { components.append(address1) }
        if let address2 = address2 { components.append(address2) }
        if let address3 = address3 { components.append(address3) }
        components.append("\(city), \(state) \(zipCode)")
        return components.joined(separator: ", ")
    }
    
    enum CodingKeys: String, CodingKey {
        case address1, address2, address3, city, state
        case zipCode = "zip_code"
        case country
    }
}

// MARK: - Yelp Coordinates Model
struct YelpCoordinates: Codable {
    let latitude: Double
    let longitude: Double
}

// MARK: - Yelp Hours Model
struct YelpHours: Codable {
    let isOpenNow: Bool
    let open: [YelpPeriod]
    
    enum CodingKeys: String, CodingKey {
        case isOpenNow = "is_open_now"
        case open
    }
}

// MARK: - Yelp Period Model
struct YelpPeriod: Codable {
    let day: Int
    let start: String
    let end: String
    let isOvernight: Bool
}

// MARK: - Yelp Review Model
struct YelpReview: Codable {
    let id: String
    let rating: Double
    let text: String
    let timeCreated: String
    let user: YelpUser
    
    enum CodingKeys: String, CodingKey {
        case id, rating, text, user
        case timeCreated = "time_created"
    }
}

// MARK: - Yelp User Model
struct YelpUser: Codable {
    let id: String
    let name: String
    let profileUrl: String?
    let imageUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case profileUrl = "profile_url"
        case imageUrl = "image_url"
    }
} 