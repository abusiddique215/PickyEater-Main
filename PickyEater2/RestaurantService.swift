import Foundation
import CoreLocation

actor RestaurantService {
    static let shared = RestaurantService()
    private let baseURL = "https://api.yelp.com/v3"
    private let apiKey: String
    private let session: URLSession
    
    init() {
        self.apiKey = ProcessInfo.processInfo.environment["YELP_API_KEY"] ?? ""
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: config)
    }
    
    func searchRestaurants(
        near location: CLLocation,
        preferences: UserPreferences,
        offset: Int = 0
    ) async throws -> [Restaurant] {
        var components = URLComponents(string: "\(baseURL)/businesses/search")!
        
        // Convert price range to Yelp format (1,2,3,4)
        let priceFilter = String(preferences.priceRange)
        
        // Parameters
        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(location.coordinate.latitude)),
            URLQueryItem(name: "longitude", value: String(location.coordinate.longitude)),
            URLQueryItem(name: "radius", value: String(min(40000, preferences.maxDistance * 1000))), // Max 40km per Yelp API
            URLQueryItem(name: "categories", value: "restaurants,food"),
            URLQueryItem(name: "limit", value: "50"), // Maximum allowed by Yelp
            URLQueryItem(name: "offset", value: String(offset)),
            URLQueryItem(name: "sort_by", value: "distance"),
            URLQueryItem(name: "open_now", value: "true")
        ]
        
        // Add optional filters
        if preferences.priceRange > 0 {
            components.queryItems?.append(URLQueryItem(name: "price", value: priceFilter))
        }
        
        if !preferences.cuisinePreferences.isEmpty {
            let categories = preferences.cuisinePreferences.joined(separator: ",").lowercased()
            components.queryItems?.append(URLQueryItem(name: "categories", value: categories))
        }
        
        var request = URLRequest(url: components.url!)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        print("Searching restaurants near: lat=\(location.coordinate.latitude), lon=\(location.coordinate.longitude), radius=\(preferences.maxDistance * 1000)")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }
            
            if httpResponse.statusCode == 429 {
                // Rate limit hit - wait and retry
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                return try await searchRestaurants(near: location, preferences: preferences, offset: offset)
            }
            
            guard httpResponse.statusCode == 200 else {
                if let errorString = String(data: data, encoding: .utf8) {
                    print("API Error (\(httpResponse.statusCode)): \(errorString)")
                }
                throw URLError(.badServerResponse)
            }
            
            let decoder = JSONDecoder()
            let yelpResponse = try decoder.decode(RestaurantSearchResponse.self, from: data)
            print("Found \(yelpResponse.businesses.count) restaurants")
            
            // Filter results based on dietary restrictions
            let filteredRestaurants = yelpResponse.businesses.filter { restaurant in
                guard !preferences.dietaryRestrictions.isEmpty else { return true }
                return restaurant.categories.contains { category in
                    preferences.dietaryRestrictions.contains { restriction in
                        category.alias.contains(restriction.lowercased()) ||
                        category.title.lowercased().contains(restriction.lowercased())
                    }
                }
            }
            
            // If we have few results and there are more available, fetch the next page
            if filteredRestaurants.count < 10 && yelpResponse.total > offset + yelpResponse.businesses.count {
                let nextPageRestaurants = try await searchRestaurants(
                    near: location,
                    preferences: preferences,
                    offset: offset + yelpResponse.businesses.count
                )
                return filteredRestaurants + nextPageRestaurants
            }
            
            return filteredRestaurants
        } catch {
            print("Search failed: \(error.localizedDescription)")
            throw error
        }
    }
} 