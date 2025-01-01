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
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: config)
    }
    
    func searchRestaurants(
        near location: CLLocation,
        preferences: UserPreferences
    ) async throws -> [Restaurant] {
        var components = URLComponents(string: "\(baseURL)/businesses/search")!
        
        // Convert price range to Yelp format (1,2,3,4)
        let priceFilter = preferences.priceRange.map { String($0) }.joined(separator: ",")
        
        // Calculate radius in meters (as integer)
        let radiusInMeters = Int(round(min(40000, preferences.maxDistance * 1000)))
        
        // Parameters
        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(format: "%.6f", location.coordinate.latitude)),
            URLQueryItem(name: "longitude", value: String(format: "%.6f", location.coordinate.longitude)),
            URLQueryItem(name: "radius", value: "\(radiusInMeters)"), // Use string interpolation for clean integer
            URLQueryItem(name: "categories", value: "restaurants"),
            URLQueryItem(name: "limit", value: "50"), // Maximum allowed by Yelp
            URLQueryItem(name: "sort_by", value: "distance"),
            URLQueryItem(name: "open_now", value: "true")
        ]
        
        // Add optional filters
        if !priceFilter.isEmpty {
            components.queryItems?.append(URLQueryItem(name: "price", value: priceFilter))
        }
        
        if !preferences.cuisinePreferences.isEmpty {
            let categories = preferences.cuisinePreferences.joined(separator: ",").lowercased()
            components.queryItems?.append(URLQueryItem(name: "categories", value: categories))
        }
        
        guard let url = components.url else {
            print("❌ Failed to construct URL with components: \(components)")
            throw YelpAPIError.invalidResponse
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(Config.yelpAPIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        print("🔍 Searching restaurants near: lat=\(location.coordinate.latitude), lon=\(location.coordinate.longitude), radius=\(radiusInMeters)m")
        print("🔗 URL: \(url)")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response type")
                throw YelpAPIError.invalidResponse
            }
            
            if let errorString = String(data: data, encoding: .utf8) {
                print("📡 Response (\(httpResponse.statusCode)): \(errorString)")
            }
            
            guard httpResponse.statusCode == 200 else {
                throw YelpAPIError.invalidResponse
            }
            
            let searchResponse = try decoder.decode(RestaurantSearchResponse.self, from: data)
            print("✅ Found \(searchResponse.businesses.count) restaurants")
            
            if searchResponse.businesses.isEmpty {
                print("⚠️ No restaurants found, falling back to Apple Maps...")
                return try await searchWithAppleMaps(near: location)
            }
            
            return searchResponse.businesses
        } catch {
            print("❌ Search failed: \(error.localizedDescription)")
            print("⚠️ Falling back to Apple Maps...")
            return try await searchWithAppleMaps(near: location)
        }
    }
    
    // Fallback to Apple Maps search if Yelp API fails
    func searchWithAppleMaps(near location: CLLocation, radius: Int = 5000) async throws -> [Restaurant] {
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