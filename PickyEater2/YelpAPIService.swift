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
        preferences: UserPreferences,
        searchQuery: String = "",
        offset: Int = 0
    ) async throws -> [Restaurant] {
        var components = URLComponents(string: "\(baseURL)/businesses/search")!
        
        // Convert price range to Yelp format (1,2,3,4)
        let priceFilter = String(preferences.priceRange)
        
        // Parameters
        var queryItems = [
            URLQueryItem(name: "latitude", value: String(location.coordinate.latitude)),
            URLQueryItem(name: "longitude", value: String(location.coordinate.longitude)),
            URLQueryItem(name: "limit", value: "50"), // Adjust as needed
            URLQueryItem(name: "offset", value: String(offset)),
            URLQueryItem(name: "price", value: priceFilter)
        ]
        
        if !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty {
            queryItems.append(URLQueryItem(name: "term", value: searchQuery))
        }
        
        components.queryItems = queryItems
        
        var request = URLRequest(url: components.url!)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw YelpAPIError.invalidResponse
        }
        
        // Decode the response
        let yelpResponse = try decoder.decode(RestaurantSearchResponse.self, from: data)
        
        // Process and return restaurants
        return yelpResponse.businesses
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