import Foundation

class YelpAPIService {
    let apiKey: String
    private let baseURL = "https://api.yelp.com/v3"
    
    init(apiKey: String) {
        self.apiKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func convertPriceToYelpFormat(_ price: String) -> String {
        let count = price.filter { $0 == "$" }.count
        return String(count)
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
        request.timeoutInterval = 30
        
        print("Making request to: \(url.absoluteString)")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            if httpResponse.statusCode != 200 {
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Error Response (\(httpResponse.statusCode)): \(responseString)")
                }
            }
            
            switch httpResponse.statusCode {
            case 200:
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                do {
                    let searchResponse = try decoder.decode(RestaurantSearchResponse.self, from: data)
                    return searchResponse.businesses
                } catch {
                    print("Decoding error: \(error)")
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("Response data: \(responseString)")
                    }
                    throw APIError.invalidData
                }
            case 400:
                throw APIError.invalidRequest
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
                return "Please check your Yelp API key"
            case .invalidAPIKey:
                return "Invalid API key. Please check your Yelp API key."
            case .invalidResponse:
                return "Invalid response from server. Please try again."
            case .invalidData:
                return "Could not understand the server response. Please try again."
            case .invalidRequest:
                return "Invalid search criteria. Please adjust your preferences."
            case .rateLimitExceeded:
                return "Too many requests. Please try again in a few minutes."
            case .serverError(let statusCode):
                return "Server error (Status: \(statusCode)). Please try again."
            case .networkError(let error):
                return "Network error: \(error.localizedDescription)"
            }
        }
    }
} 