import Foundation

class YelpAPIService {
    let apiKey: String
    private let baseURL = "https://api.yelp.com/v3"
    
    init(apiKey: String) {
        self.apiKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func convertPriceToYelpFormat(_ price: String) -> String {
        let count = price.filter { $0 == "$" }.count
        return (1...count).map { String($0) }.joined(separator: ",")
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
        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(format: "%.6f", latitude)),
            URLQueryItem(name: "longitude", value: String(format: "%.6f", longitude)),
            URLQueryItem(name: "sort_by", value: "rating"),
            URLQueryItem(name: "limit", value: "20"),
            URLQueryItem(name: "term", value: "restaurants")
        ]
        
        if let categories = categories, !categories.isEmpty {
            let cleanedCategories = categories.map { $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) }
            components.queryItems?.append(URLQueryItem(name: "categories", value: cleanedCategories.joined(separator: ",")))
        }
        
        if let price = price, !price.isEmpty {
            components.queryItems?.append(URLQueryItem(name: "price", value: convertPriceToYelpFormat(price)))
        }
        
        if let radius = radius {
            let clampedRadius = min(max(radius, 1000), 40000)
            components.queryItems?.append(URLQueryItem(name: "radius", value: String(clampedRadius)))
        }
        
        guard let url = components.url else {
            throw APIError.invalidRequest
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        print("Making request to: \(url.absoluteString)")
        print("With Authorization: Bearer \(apiKey)")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response (\(httpResponse.statusCode)): \(responseString)")
            }
            
            switch httpResponse.statusCode {
            case 200:
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let searchResponse = try decoder.decode(RestaurantSearchResponse.self, from: data)
                return searchResponse.businesses
            case 400:
                throw APIError.invalidRequest
            case 401:
                throw APIError.invalidAPIKey
            case 429:
                throw APIError.rateLimitExceeded
            default:
                throw APIError.serverError(statusCode: httpResponse.statusCode)
            }
        } catch let error as DecodingError {
            print("Decoding error: \(error)")
            throw APIError.invalidData
        } catch let error as APIError {
            throw error
        } catch {
            print("Network error: \(error)")
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
        case invalidRequest
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
                return "Could not parse the response from server."
            case .invalidRequest:
                return "Invalid request parameters. Please check your search criteria."
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