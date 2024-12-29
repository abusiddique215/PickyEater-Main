import Foundation

class YelpAPIService {
    private let apiKey: String
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
        var components = URLComponents(string: "\(baseURL)/businesses/search")!
        
        var queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "sort_by", value: "rating"),
            URLQueryItem(name: "limit", value: "20")
        ]
        
        if let categories = categories {
            queryItems.append(URLQueryItem(name: "categories", value: categories.joined(separator: ",")))
        }
        
        if let price = price {
            queryItems.append(URLQueryItem(name: "price", value: price))
        }
        
        if let radius = radius {
            queryItems.append(URLQueryItem(name: "radius", value: String(radius)))
        }
        
        components.queryItems = queryItems
        
        var request = URLRequest(url: components.url!)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let searchResponse = try JSONDecoder().decode(RestaurantSearchResponse.self, from: data)
        return searchResponse.businesses
    }
}

// MARK: - Error Handling
extension YelpAPIService {
    enum APIError: Error {
        case invalidResponse
        case invalidData
        case networkError(Error)
    }
} 