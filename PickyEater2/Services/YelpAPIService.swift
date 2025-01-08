import Foundation

actor YelpAPIService {
    private let baseURL = "https://api.yelp.com/v3"
    private let apiKey: String
    private let session: URLSession
    
    init() {
        // In a real app, this would be stored securely in the keychain or environment
        apiKey = "YOUR_YELP_API_KEY"
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        session = URLSession(configuration: config)
    }
    
    func searchRestaurants(
        latitude: Double,
        longitude: Double,
        term: String? = nil,
        categories: String? = nil,
        price: String? = nil,
        radius: Int? = nil,
        limit: Int = 20,
        offset: Int = 0
    ) async throws -> [YelpBusiness] {
        var components = URLComponents(string: "\(baseURL)/businesses/search")!
        
        // Required parameters
        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "offset", value: String(offset))
        ]
        
        // Optional parameters
        if let term = term {
            components.queryItems?.append(URLQueryItem(name: "term", value: term))
        }
        
        if let categories = categories {
            components.queryItems?.append(URLQueryItem(name: "categories", value: categories))
        }
        
        if let price = price {
            components.queryItems?.append(URLQueryItem(name: "price", value: price))
        }
        
        if let radius = radius {
            components.queryItems?.append(URLQueryItem(name: "radius", value: String(radius)))
        }
        
        var request = URLRequest(url: components.url!)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200:
            let decoder = JSONDecoder()
            let searchResponse = try decoder.decode(YelpSearchResponse.self, from: data)
            return searchResponse.businesses
        case 401:
            throw APIError.unauthorized
        case 429:
            throw APIError.rateLimitExceeded
        default:
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }
    }
    
    func fetchBusinessDetails(id: String) async throws -> YelpBusiness {
        let url = URL(string: "\(baseURL)/businesses/\(id)")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200:
            let decoder = JSONDecoder()
            return try decoder.decode(YelpBusiness.self, from: data)
        case 401:
            throw APIError.unauthorized
        case 429:
            throw APIError.rateLimitExceeded
        default:
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }
    }
}

// MARK: - API Error

enum APIError: LocalizedError {
    case invalidResponse
    case unauthorized
    case rateLimitExceeded
    case httpError(statusCode: Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from the server."
        case .unauthorized:
            return "Unauthorized access. Please check your API key."
        case .rateLimitExceeded:
            return "Rate limit exceeded. Please try again later."
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        }
    }
}

// MARK: - Yelp Models

struct YelpSearchResponse: Codable {
    let businesses: [YelpBusiness]
    let total: Int
}

struct YelpBusiness: Codable {
    let id: String
    let name: String
    let imageUrl: String
    let url: String
    let rating: Double
    let reviewCount: Int
    let price: String?
    let phone: String
    let distance: Double
    let categories: [YelpCategory]
    let coordinates: YelpCoordinates
    let location: YelpLocation
    let hours: [YelpHours]?
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
    let address1: String
    let city: String
    let state: String
    let zipCode: String
    let country: String
    
    enum CodingKeys: String, CodingKey {
        case address1
        case city
        case state
        case zipCode = "zip_code"
        case country
    }
}

struct YelpHours: Codable {
    let open: [YelpOpenHours]
    let hoursType: String
    let isOpenNow: Bool
    
    enum CodingKeys: String, CodingKey {
        case open
        case hoursType = "hours_type"
        case isOpenNow = "is_open_now"
    }
}

struct YelpOpenHours: Codable {
    let day: Int
    let start: String
    let end: String
    let isOvernight: Bool
    
    enum CodingKeys: String, CodingKey {
        case day
        case start
        case end
        case isOvernight = "is_overnight"
    }
}
