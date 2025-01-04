import Foundation
import CoreLocation
import MapKit

enum YelpAPIError: Error {
    case networkError(Error)
    case invalidResponse
    case noData
    case decodingError(Error)
    case invalidLocation
}

class YelpAPIService {
    static let shared = YelpAPIService()
    private let baseURL = "https://api.yelp.com/v3"
    private let session: URLSession
    private let decoder = JSONDecoder()
    private let apiKey: String
    
    private init() {
        // Fetch API key from environment variables
        self.apiKey = ProcessInfo.processInfo.environment["YELP_API_KEY"] ?? ""
        print("📝 API Key status: \(self.apiKey.isEmpty ? "❌ Not found" : "✅ Found (\(self.apiKey.prefix(6))...)")")
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: config)
    }
    
    func searchRestaurants(
        near location: CLLocation,
        preferences: UserPreferences
    ) async throws -> [Restaurant] {
        // Verify location is valid
        guard CLLocationCoordinate2D(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        ).isValid else {
            print("❌ Invalid coordinates: \(location.coordinate)")
            throw YelpAPIError.invalidLocation
        }
        
        print("📍 Starting restaurant search:")
        print("- Location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        print("- Max Distance: \(preferences.maxDistance)km")
        print("- Price Range: \(preferences.priceRange)")
        print("- Dietary Restrictions: \(preferences.dietaryRestrictions)")
        print("- Cuisine Preferences: \(preferences.cuisinePreferences)")
        
        // Verify API key
        guard !apiKey.isEmpty else {
            print("❌ No Yelp API key found - falling back to Apple Maps")
            return try await searchWithAppleMaps(near: location)
        }
        
        // Build URL with explicit integer radius
        let radiusInMeters: Int = min(preferences.maxDistance * 1000, 40000) // Max 40km per Yelp API
        let latitude = String(format: "%.6f", location.coordinate.latitude)
        let longitude = String(format: "%.6f", location.coordinate.longitude)
        
        // Create search terms based on dietary restrictions
        var searchTerms = ["restaurants"]
        var attributes: [String] = []
        var categories: [String] = []
        
        // Handle dietary restrictions
        for restriction in preferences.dietaryRestrictions {
            switch restriction.lowercased() {
            case "vegetarian":
                categories.append("vegetarian")
                attributes.append("vegetarian")
            case "vegan":
                categories.append("vegan")
                attributes.append("vegan")
            case "gluten-free":
                categories.append("gluten_free")
                attributes.append("gluten_free")
            case "halal":
                categories.append("halal")
            case "kosher":
                categories.append("kosher")
            case "dairy-free":
                searchTerms.append("dairy-free")
            default:
                break
            }
        }
        
        // Add cuisine preferences to categories
        if !preferences.cuisinePreferences.isEmpty {
            categories.append(contentsOf: preferences.cuisinePreferences)
        }
        
        // Construct URL components manually to ensure proper encoding
        var components = URLComponents(string: "\(baseURL)/businesses/search")!
        components.queryItems = [
            URLQueryItem(name: "latitude", value: latitude),
            URLQueryItem(name: "longitude", value: longitude),
            URLQueryItem(name: "radius", value: String(radiusInMeters)),
            URLQueryItem(name: "term", value: searchTerms.joined(separator: " ")),
            URLQueryItem(name: "limit", value: "50"), // Increased from 20 to 50
            URLQueryItem(name: "sort_by", value: "distance"),
            URLQueryItem(name: "price", value: String(preferences.priceRange))
        ]
        
        // Add attributes if any
        if !attributes.isEmpty {
            components.queryItems?.append(
                URLQueryItem(name: "attributes", value: attributes.joined(separator: ","))
            )
        }
        
        // Add categories if any
        if !categories.isEmpty {
            components.queryItems?.append(
                URLQueryItem(name: "categories", value: categories.joined(separator: ","))
            )
        }
        
        guard let url = components.url else {
            print("❌ Failed to construct URL")
            throw YelpAPIError.invalidResponse
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        print("🔍 API Request Details:")
        print("- URL: \(url)")
        print("- Search Terms: \(searchTerms)")
        print("- Categories: \(categories)")
        print("- Attributes: \(attributes)")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response type")
                throw YelpAPIError.invalidResponse
            }
            
            print("📡 Response Status: \(httpResponse.statusCode)")
            
            switch httpResponse.statusCode {
            case 200:
                let searchResponse = try decoder.decode(RestaurantSearchResponse.self, from: data)
                print("✅ Found \(searchResponse.businesses.count) restaurants")
                
                // Additional filtering for dietary restrictions that can't be handled by the API
                let filteredRestaurants = searchResponse.businesses.filter { restaurant in
                    // If no dietary restrictions, include all restaurants
                    guard !preferences.dietaryRestrictions.isEmpty else { return true }
                    
                    // Check if restaurant categories or title contain any of our dietary keywords
                    let restaurantKeywords = restaurant.categories.map { $0.title.lowercased() }
                        .joined(separator: " ")
                        .split(separator: " ")
                        .map(String.init)
                    
                    // Check if any of the restaurant's categories match our dietary restrictions
                    let matchesDietary = preferences.dietaryRestrictions.contains { restriction in
                        let restrictionKeywords = restriction.lowercased().split(separator: "-").map(String.init)
                        return restrictionKeywords.allSatisfy { keyword in
                            restaurantKeywords.contains { $0.contains(keyword) }
                        }
                    }
                    
                    return matchesDietary
                }
                
                if filteredRestaurants.isEmpty {
                    print("⚠️ No restaurants found with specified dietary restrictions")
                    // Instead of falling back to Apple Maps, return the unfiltered results
                    return searchResponse.businesses
                }
                
                return filteredRestaurants
                
            case 400:
                print("❌ Bad request - Check parameters")
                if let errorString = String(data: data, encoding: .utf8) {
                    print("Error details: \(errorString)")
                }
                return try await searchWithAppleMaps(near: location)
                
            case 429:
                print("❌ Rate limit exceeded - Retrying after delay")
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                return try await searchRestaurants(near: location, preferences: preferences)
                
            default:
                print("❌ Unexpected status code: \(httpResponse.statusCode)")
                return try await searchWithAppleMaps(near: location)
            }
            
        } catch {
            print("❌ Search failed: \(error.localizedDescription)")
            print("⚠️ Falling back to Apple Maps...")
            return try await searchWithAppleMaps(near: location)
        }
    }
    
    private func searchWithAppleMaps(near location: CLLocation, radius: Int = 1000) async throws -> [Restaurant] {
        let region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: Double(radius),
            longitudinalMeters: Double(radius)
        )
        
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = "restaurants"
        searchRequest.region = region
        
        let search = MKLocalSearch(request: searchRequest)
        let response = try await search.start()
        
        print("🗺 Found \(response.mapItems.count) restaurants using Apple Maps")
        
        let jsonData = try JSONSerialization.data(withJSONObject: response.mapItems.map { mapItem in
            [
                "id": mapItem.placemark.title ?? UUID().uuidString,
                "name": mapItem.name ?? "Unknown Restaurant",
                "location": [
                    "address1": mapItem.placemark.thoroughfare ?? "",
                    "city": mapItem.placemark.locality ?? "",
                    "state": mapItem.placemark.administrativeArea ?? "",
                    "country": mapItem.placemark.country ?? "",
                    "lat": mapItem.placemark.coordinate.latitude,
                    "lng": mapItem.placemark.coordinate.longitude,
                    "zip_code": mapItem.placemark.postalCode ?? ""
                ],
                "categories": [] as [[String: String]],
                "image_url": "",
                "rating": 0,
                "review_count": 0,
                "price": NSNull(),
                "display_phone": mapItem.phoneNumber ?? ""
            ] as [String: Any]
        })
        
        return try decoder.decode([Restaurant].self, from: jsonData)
    }
}

// MARK: - Helpers
extension CLLocationCoordinate2D {
    var isValid: Bool {
        latitude >= -90 && latitude <= 90 &&
        longitude >= -180 && longitude <= 180
    }
} 