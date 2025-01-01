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
        // Get API key from environment
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
        let radiusInMeters: Int = preferences.maxDistance * 1000 // Convert km to meters
        let latitude = String(format: "%.6f", location.coordinate.latitude)
        let longitude = String(format: "%.6f", location.coordinate.longitude)
        
        // Construct URL components manually to ensure proper encoding
        var components = URLComponents(string: "\(baseURL)/businesses/search")!
        components.queryItems = [
            URLQueryItem(name: "latitude", value: latitude),
            URLQueryItem(name: "longitude", value: longitude),
            URLQueryItem(name: "radius", value: String(radiusInMeters)),
            URLQueryItem(name: "term", value: "restaurants"),
            URLQueryItem(name: "limit", value: "20"),
            URLQueryItem(name: "sort_by", value: "distance"),
            URLQueryItem(name: "price", value: String(preferences.priceRange))
        ]
        
        // Add cuisine preferences if any
        if !preferences.cuisinePreferences.isEmpty {
            components.queryItems?.append(
                URLQueryItem(name: "categories", value: preferences.cuisinePreferences.joined(separator: ","))
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
        print("- Headers: \(request.allHTTPHeaderFields ?? [:])")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response type")
                throw YelpAPIError.invalidResponse
            }
            
            print("📡 Response Status: \(httpResponse.statusCode)")
            
            // Always print response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("📡 Raw Response: \(responseString)")
            }
            
            switch httpResponse.statusCode {
            case 200:
                let searchResponse = try decoder.decode(RestaurantSearchResponse.self, from: data)
                print("✅ Found \(searchResponse.businesses.count) restaurants")
                
                if searchResponse.businesses.isEmpty {
                    print("⚠️ No restaurants found with Yelp, trying Apple Maps...")
                    return try await searchWithAppleMaps(near: location)
                }
                
                return searchResponse.businesses
                
            case 401:
                print("❌ Authentication failed - Invalid API key")
                return try await searchWithAppleMaps(near: location)
                
            case 400:
                print("❌ Bad request - Check parameters")
                if let errorString = String(data: data, encoding: .utf8) {
                    print("Error details: \(errorString)")
                }
                return try await searchWithAppleMaps(near: location)
                
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
    
    private func searchRestaurantsWithLargerRadius(
        near location: CLLocation,
        preferences: UserPreferences,
        radius: Int = 5000
    ) async throws -> [Restaurant] {
        print("🔄 Retrying search with \(radius)m radius...")
        // Create new preferences with modified radius
        let modifiedPreferences = UserPreferences(
            maxDistance: radius / 1000,
            priceRange: preferences.priceRange,
            dietaryRestrictions: preferences.dietaryRestrictions,
            cuisinePreferences: preferences.cuisinePreferences,
            theme: preferences.theme
        )
        return try await searchRestaurants(near: location, preferences: modifiedPreferences)
    }
    
    // Fallback to Apple Maps search if Yelp API fails
    func searchWithAppleMaps(near location: CLLocation, radius: Int = 1000) async throws -> [Restaurant] {
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