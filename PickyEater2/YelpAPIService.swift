import Foundation
import CoreLocation
@_exported import Models

struct YelpAPIService {
    private let apiKey: String
    private let session: URLSession
    private let baseURL = "https://api.yelp.com/v3"
    
    init(apiKey: String) {
        self.apiKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = [
            "Authorization": "Bearer \(apiKey)",
            "Accept": "application/json"
        ]
        self.session = URLSession(configuration: config)
    }
    
    func searchRestaurants(latitude: Double, longitude: Double, radius: Int = 5000, categories: [String]? = nil) async throws -> [YelpRestaurant] {
        var components = URLComponents(string: "\(baseURL)/businesses/search")!
        
        var queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "radius", value: String(radius)),
            URLQueryItem(name: "limit", value: "20"),
            URLQueryItem(name: "sort_by", value: "distance"),
            URLQueryItem(name: "term", value: "restaurants")
        ]
        
        if let categories = categories, !categories.isEmpty {
            queryItems.append(URLQueryItem(name: "categories", value: categories.joined(separator: ",")))
        }
        
        components.queryItems = queryItems
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        
        let (data, _) = try await session.data(for: request)
        let response = try JSONDecoder().decode(YelpSearchResponse.self, from: data)
        return response.businesses
    }
}

// MARK: - Yelp API Response Models
struct YelpSearchResponse: Codable {
    let businesses: [YelpRestaurant]
    let total: Int
}

struct YelpRestaurant: Codable, Identifiable {
    let id: String
    let name: String
    let imageURL: URL?
    let url: URL
    let reviewCount: Int
    let categories: [YelpCategory]
    let rating: Double
    let coordinates: YelpCoordinates
    let price: String?
    let location: YelpLocation
    let phone: String?
    let displayPhone: String?
    let distance: Double?
    
    enum CodingKeys: String, CodingKey {
        case id, name, url, categories, rating, coordinates, price, location, phone, distance
        case imageURL = "image_url"
        case reviewCount = "review_count"
        case displayPhone = "display_phone"
    }
}

struct YelpCategory: Codable {
    let alias: String
    let title: String
}

struct YelpCoordinates: Codable {
    let latitude: Double
    let longitude: Double
}

struct YelpLocation: Codable {
    let address1: String?
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

// MARK: - Conversion to App Models
extension YelpRestaurant {
    func toRestaurant() -> Restaurant {
        Restaurant(
            id: id,
            name: name,
            location: Location(
                address1: location.address1 ?? "",
                city: location.city,
                state: location.state,
                country: location.country,
                latitude: coordinates.latitude,
                longitude: coordinates.longitude,
                zipCode: location.zipCode
            ),
            categories: categories.map { Category(alias: $0.alias, title: $0.title) },
            photos: [imageURL?.absoluteString].compactMap { $0 },
            rating: rating,
            reviewCount: reviewCount,
            price: price,
            displayPhone: displayPhone
        )
    }
} 