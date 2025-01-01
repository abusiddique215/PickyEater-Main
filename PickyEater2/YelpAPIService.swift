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

actor YelpAPIService {
    private let apiKey: String
    private let session: URLSession
    private let baseURL = "https://api.yelp.com/v3"
    private let decoder: JSONDecoder
    
    init(apiKey: String) {
        self.apiKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = [
            "Authorization": "Bearer \(apiKey)",
            "Accept": "application/json"
        ]
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        config.waitsForConnectivity = true
        
        self.session = URLSession(configuration: config)
        self.decoder = JSONDecoder()
    }
    
    func searchRestaurants(latitude: Double, longitude: Double, radius: Int = 5000, categories: [String]? = nil) async throws -> [YelpRestaurant] {
        // Validate coordinates
        guard CLLocationCoordinate2D(latitude: latitude, longitude: longitude).isValid else {
            print("❌ Invalid coordinates: lat=\(latitude), lon=\(longitude)")
            throw YelpAPIError.invalidLocation
        }
        
        var components = URLComponents(string: "\(baseURL)/businesses/search")!
        
        var queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "radius", value: String(radius)),
            URLQueryItem(name: "limit", value: "20"),
            URLQueryItem(name: "sort_by", value: "distance"),
            URLQueryItem(name: "term", value: "restaurants")
        ]
        
        if let categories = categories, !categories.isEmpty {
            queryItems.append(URLQueryItem(name: "categories", value: categories.joined(separator: ",")))
        }
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            print("❌ Failed to construct URL with components: \(components)")
            throw YelpAPIError.invalidResponse
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        print("🔍 Searching restaurants near: lat=\(latitude), lon=\(longitude), radius=\(radius)m")
        if let categories = categories, !categories.isEmpty {
            print("📋 Categories: \(categories.joined(separator: ", "))")
        }
        
        // Implement retry logic
        let maxRetries = 3
        var lastError: Error?
        
        for attempt in 1...maxRetries {
            do {
                let (data, response) = try await session.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw YelpAPIError.invalidResponse
                }
                
                guard httpResponse.statusCode == 200 else {
                    print("❌ HTTP Error: \(httpResponse.statusCode)")
                    if let errorString = String(data: data, encoding: .utf8) {
                        print("Error response: \(errorString)")
                    }
                    throw YelpAPIError.invalidResponse
                }
                
                let searchResponse = try decoder.decode(YelpSearchResponse.self, from: data)
                print("✅ Found \(searchResponse.businesses.count) restaurants")
                return searchResponse.businesses
                
            } catch {
                lastError = error
                print("❌ Attempt \(attempt) failed: \(error.localizedDescription)")
                if attempt < maxRetries {
                    let delay = Double(attempt) * 2
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    print("🔄 Retrying... (Attempt \(attempt + 1) of \(maxRetries))")
                }
            }
        }
        
        throw YelpAPIError.networkError(lastError ?? YelpAPIError.noData)
    }
    
    // Fallback to Apple Maps search if Yelp API fails
    func searchWithAppleMaps(latitude: Double, longitude: Double, radius: Int = 5000) async throws -> [MKMapItem] {
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegion(center: location, latitudinalMeters: Double(radius), longitudinalMeters: Double(radius))
        
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = "restaurants"
        searchRequest.region = region
        
        let search = MKLocalSearch(request: searchRequest)
        let response = try await search.start()
        
        print("🗺 Found \(response.mapItems.count) restaurants using Apple Maps")
        return response.mapItems
    }
}

// MARK: - Yelp API Response Models
struct YelpSearchResponse: Codable {
    let businesses: [YelpRestaurant]
    let total: Int
}

struct YelpRestaurant: Codable, Identifiable {
    let id: String
    let name: String
    let imageURL: URL?
    let url: URL
    let reviewCount: Int
    let categories: [YelpCategory]
    let rating: Double
    let coordinates: YelpCoordinates
    let price: String?
    let location: YelpLocation
    let phone: String?
    let displayPhone: String?
    let distance: Double?
    
    enum CodingKeys: String, CodingKey {
        case id, name, url, categories, rating, coordinates, price, location, phone, distance
        case imageURL = "image_url"
        case reviewCount = "review_count"
        case displayPhone = "display_phone"
    }
}

struct YelpCategory: Codable {
    let alias: String
    let title: String
}

struct YelpCoordinates: Codable {
    let latitude: Double
    let longitude: Double
}

struct YelpLocation: Codable {
    let address1: String?
    let address2: String?
    let address3: String?
    let city: String
    let zipCode: String
    let country: String
    let state: String
    let displayAddress: [String]
    
    enum CodingKeys: String, CodingKey {
        case address1, address2, address3, city, country, state
        case zipCode = "zip_code"
        case displayAddress = "display_address"
    }
}

// MARK: - Helpers
extension CLLocationCoordinate2D {
    var isValid: Bool {
        latitude >= -90 && latitude <= 90 && longitude >= -180 && longitude <= 180
    }
}

// MARK: - Conversion to App Models
extension YelpRestaurant {
    func toRestaurant() -> Restaurant {
        Restaurant(
            id: id,
            name: name,
            location: Location(
                address1: location.address1 ?? "",
                city: location.city,
                state: location.state,
                country: location.country,
                latitude: coordinates.latitude,
                longitude: coordinates.longitude,
                zipCode: location.zipCode
            ),
            categories: categories.map { Category(alias: $0.alias, title: $0.title) },
            photos: [imageURL?.absoluteString].compactMap { $0 },
            rating: rating,
            reviewCount: reviewCount,
            price: price,
            displayPhone: displayPhone
        )
    }
}

// MARK: - Apple Maps Conversion
extension MKMapItem {
    func toRestaurant() -> Restaurant {
        Restaurant(
            id: placemark.title ?? UUID().uuidString,
            name: name ?? "Unknown Restaurant",
            location: Location(
                address1: placemark.thoroughfare ?? "",
                city: placemark.locality ?? "",
                state: placemark.administrativeArea ?? "",
                country: placemark.country ?? "",
                latitude: placemark.coordinate.latitude,
                longitude: placemark.coordinate.longitude,
                zipCode: placemark.postalCode
            ),
            categories: [], // Apple Maps doesn't provide detailed categories
            photos: [], // Apple Maps doesn't provide photos
            rating: 0, // Apple Maps doesn't provide ratings
            reviewCount: 0,
            price: nil,
            displayPhone: phoneNumber
        )
    }
} 