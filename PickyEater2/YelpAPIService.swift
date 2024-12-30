import Foundation

struct RestaurantSearchResponse: Codable {
    let businesses: [Restaurant]
    let total: Int
    let region: Region
    
    struct Region: Codable {
        let center: Restaurant.Coordinates
    }
}

actor YelpAPIService {
    private let apiKey: String
    private let baseURL = "https://api.yelp.com/v3"
    private var urlSession: URLSession
    
    init(apiKey: String) {
        self.apiKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = [
            "Authorization": "Bearer \(apiKey)",
            "Accept": "application/json"
        ]
        self.urlSession = URLSession(configuration: config)
        
        print("YelpAPIService initialized with API key length: \(apiKey.count)")
    }
    
    func searchRestaurants(
        latitude: Double,
        longitude: Double,
        categories: [String] = [],
        price: String? = nil,
        radius: Int? = nil,
        limit: Int = 20
    ) async throws -> [Restaurant] {
        var components = URLComponents(string: "\(baseURL)/businesses/search")!
        
        // Required parameters
        var queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "term", value: "restaurants"),
            URLQueryItem(name: "sort_by", value: "distance"),
            URLQueryItem(name: "limit", value: String(limit))
        ]
        
        // Optional parameters
        if !categories.isEmpty {
            queryItems.append(URLQueryItem(name: "categories", value: categories.joined(separator: ",")))
        }
        
        if let price = price {
            queryItems.append(URLQueryItem(name: "price", value: price))
        }
        
        if let radius = radius {
            queryItems.append(URLQueryItem(name: "radius", value: String(radius)))
        }
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        
        print("Fetching restaurants from URL: \(url)")
        
        let (data, response) = try await urlSession.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard httpResponse.statusCode == 200 else {
            print("Error response: \(httpResponse.statusCode)")
            if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                print("Error details: \(errorJson)")
            }
            throw URLError(.badServerResponse)
        }
        
        do {
            let decoder = JSONDecoder()
            let searchResponse = try decoder.decode(RestaurantSearchResponse.self, from: data)
            return searchResponse.businesses
        } catch {
            print("Decoding error: \(error)")
            throw error
        }
    }
} 