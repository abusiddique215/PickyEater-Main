import Foundation

class YelpAPIService {
    let apiKey: String
    private let baseURL = "https://api.yelp.com/v3"
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func searchRestaurants(
        latitude: Double,
        longitude: Double,
        categories: [String]? = nil,
        price: String? = nil,
        radius: Int? = nil
    ) async throws -> [Restaurant] {
        if apiKey.isEmpty {
            throw APIError.missingAPIKey
        }
        
        var components = URLComponents(string: "\(baseURL)/businesses/search")!
        
        var queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "sort_by", value: "rating"),
            URLQueryItem(name: "limit", value: "20")
        ]
        
        if let categories = categories, !categories.isEmpty {
            queryItems.append(URLQueryItem(name: "categories", value: categories.joined(separator: ",")))
        }
        
        if let price = price, !price.isEmpty {
            // Convert $$ format to 1,2 format that Yelp API expects
            let priceLevel = String(repeating: "1,", count: price.count).dropLast()
            queryItems.append(URLQueryItem(name: "price", value: String(priceLevel)))
        }
        
        if let radius = radius {
            queryItems.append(URLQueryItem(name: "radius", value: String(radius)))
        }
        
        components.queryItems = queryItems
        
        var request = URLRequest(url: components.url!)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200:
                let searchResponse = try JSONDecoder().decode(RestaurantSearchResponse.self, from: data)
                return searchResponse.businesses
            case 401:
                throw APIError.invalidAPIKey
            case 429:
                throw APIError.rateLimitExceeded
            default:
                throw APIError.serverError(statusCode: httpResponse.statusCode)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
}

// MARK: - Error Handling
extension YelpAPIService {
    enum APIError: LocalizedError {
        case missingAPIKey
        case invalidAPIKey
        case invalidResponse
        case invalidData
        case rateLimitExceeded
        case serverError(statusCode: Int)
        case networkError(Error)
        
        var errorDescription: String? {
            switch self {
            case .missingAPIKey:
                return "Please add your Yelp API key in RestaurantListView.swift"
            case .invalidAPIKey:
                return "Invalid API key. Please check your Yelp API key."
            case .invalidResponse:
                return "Invalid response from server."
            case .invalidData:
                return "Invalid data received from server."
            case .rateLimitExceeded:
                return "Rate limit exceeded. Please try again later."
            case .serverError(let statusCode):
                return "Server error occurred (Status: \(statusCode))"
            case .networkError(let error):
                return "Network error: \(error.localizedDescription)"
            }
        }
    }
} 