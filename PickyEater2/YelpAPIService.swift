import Foundation
import CoreLocation
import MapKit
import Network

@MainActor
class YelpAPIService {
    static let shared = YelpAPIService()
    private let baseURL = "https://api.yelp.com/v3"
    private let session: URLSession
    private let decoder = JSONDecoder()
    private let apiKey: String
    private let networkMonitor: NetworkMonitor
    
    private init() {
        self.apiKey = ProcessInfo.processInfo.environment["YELP_API_KEY"] ?? ""
        print("📝 API Key status: \(self.apiKey.isEmpty ? "❌ Not found" : "✅ Found (\(self.apiKey.prefix(6))...)")")
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: config)
        
        // Initialize NetworkMonitor with explicit initialization
        self.networkMonitor = NetworkMonitor()
    }
    
    var isConnected: Bool {
        networkMonitor.isConnected
    }
    
    func searchRestaurants(
        near location: CLLocation,
        preferences: UserPreferences,
        searchQuery: String = "",
        offset: Int = 0
    ) async throws -> [Restaurant] {
        // Check network connectivity
        guard isConnected else {
            throw NetworkError.noInternet
        }
        
        // Validate location
        guard location.coordinate.isValid else {
            throw NetworkError.apiError("Invalid location coordinates")
        }
        
        // Create URL components and query items
        var urlComponents = URLComponents(string: "\(baseURL)/businesses/search")
        guard urlComponents != nil else {
            throw NetworkError.invalidURL
        }
        
        // Convert price range to Yelp format (1,2,3,4)
        let priceFilter = String(preferences.priceRange)
        
        // Build query items
        var queryItems = [
            URLQueryItem(name: "latitude", value: String(location.coordinate.latitude)),
            URLQueryItem(name: "longitude", value: String(location.coordinate.longitude)),
            URLQueryItem(name: "limit", value: "50"),
            URLQueryItem(name: "offset", value: String(offset)),
            URLQueryItem(name: "price", value: priceFilter)
        ]
        
        if !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty {
            queryItems.append(URLQueryItem(name: "term", value: searchQuery))
        }
        
        // Set query items
        urlComponents?.queryItems = queryItems
        
        guard let url = urlComponents?.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.serverError(0)
            }
            
            switch httpResponse.statusCode {
            case 200..<300:
                break
            case 401:
                throw NetworkError.apiError("Invalid API key")
            case 429:
                throw NetworkError.apiError("Rate limit exceeded")
            default:
                throw NetworkError.serverError(httpResponse.statusCode)
            }
            
            guard !data.isEmpty else {
                throw NetworkError.noData
            }
            
            do {
                let yelpResponse = try decoder.decode(RestaurantSearchResponse.self, from: data)
                return yelpResponse.businesses
            } catch {
                throw NetworkError.decodingError
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.apiError(error.localizedDescription)
        }
    }
    
    private func searchWithAppleMaps(near location: CLLocation, radius: Int = 1000) async throws -> [Restaurant] {
        guard networkMonitor.isConnected else {
            throw NetworkError.noInternet
        }
        
        let region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: Double(radius),
            longitudinalMeters: Double(radius)
        )
        
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = "restaurants"
        searchRequest.region = region
        
        do {
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
        } catch {
            throw NetworkError.apiError("Failed to search with Apple Maps: \(error.localizedDescription)")
        }
    }
}

// MARK: - Helpers
extension CLLocationCoordinate2D {
    var isValid: Bool {
        latitude >= -90 && latitude <= 90 &&
        longitude >= -180 && longitude <= 180
    }
} 