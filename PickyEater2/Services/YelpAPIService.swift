import Foundation
import CoreLocation

actor YelpAPIService {
    private let apiKey: String
    private let baseURL = "https://api.yelp.com/v3"
    private let session: URLSession
    
    enum YelpError: Error {
        case invalidURL
        case invalidResponse
        case networkError(Error)
        case decodingError(Error)
        case apiError(String)
        case missingAPIKey
        
        var localizedDescription: String {
            switch self {
            case .invalidURL:
                return "Invalid URL"
            case .invalidResponse:
                return "Invalid response from server"
            case .networkError(let error):
                return "Network error: \(error.localizedDescription)"
            case .decodingError(let error):
                return "Failed to decode response: \(error.localizedDescription)"
            case .apiError(let message):
                return "API error: \(message)"
            case .missingAPIKey:
                return "Yelp API key is missing"
            }
        }
    }
    
    init(apiKey: String = ProcessInfo.processInfo.environment["YELP_API_KEY"] ?? "") {
        self.apiKey = apiKey
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = [
            "Authorization": "Bearer \(apiKey)",
            "Accept": "application/json"
        ]
        self.session = URLSession(configuration: config)
    }
    
    func searchRestaurants(
        location: CLLocation,
        term: String? = nil,
        categories: [String]? = nil,
        price: PriceRange? = nil,
        radius: Int? = nil,
        limit: Int = 20,
        offset: Int = 0,
        sortBy: String = "best_match"
    ) async throws -> [Restaurant] {
        guard !apiKey.isEmpty else {
            throw YelpError.missingAPIKey
        }
        
        var components = URLComponents(string: "\(baseURL)/businesses/search")
        var queryItems = [
            URLQueryItem(name: "latitude", value: String(location.coordinate.latitude)),
            URLQueryItem(name: "longitude", value: String(location.coordinate.longitude)),
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "offset", value: String(offset)),
            URLQueryItem(name: "sort_by", value: sortBy)
        ]
        
        if let term = term {
            queryItems.append(URLQueryItem(name: "term", value: term))
        }
        
        if let categories = categories {
            queryItems.append(URLQueryItem(name: "categories", value: categories.joined(separator: ",")))
        }
        
        if let price = price {
            queryItems.append(URLQueryItem(name: "price", value: String(price.rawValue)))
        }
        
        if let radius = radius {
            queryItems.append(URLQueryItem(name: "radius", value: String(radius)))
        }
        
        components?.queryItems = queryItems
        
        guard let url = components?.url else {
            throw YelpError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw YelpError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                throw YelpError.apiError("HTTP \(httpResponse.statusCode)")
            }
            
            let searchResponse = try JSONDecoder().decode(YelpSearchResponse.self, from: data)
            return searchResponse.businesses.map { $0.toRestaurant() }
        } catch let error as DecodingError {
            throw YelpError.decodingError(error)
        } catch {
            throw YelpError.networkError(error)
        }
    }
    
    func fetchRestaurantDetails(id: String) async throws -> Restaurant {
        guard !apiKey.isEmpty else {
            throw YelpError.missingAPIKey
        }
        
        guard let url = URL(string: "\(baseURL)/businesses/\(id)") else {
            throw YelpError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw YelpError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                throw YelpError.apiError("HTTP \(httpResponse.statusCode)")
            }
            
            let business = try JSONDecoder().decode(YelpBusiness.self, from: data)
            return business.toRestaurant()
        } catch let error as DecodingError {
            throw YelpError.decodingError(error)
        } catch {
            throw YelpError.networkError(error)
        }
    }
    
    func fetchReviews(for id: String) async throws -> [Review] {
        guard !apiKey.isEmpty else {
            throw YelpError.missingAPIKey
        }
        
        guard let url = URL(string: "\(baseURL)/businesses/\(id)/reviews") else {
            throw YelpError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw YelpError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                throw YelpError.apiError("HTTP \(httpResponse.statusCode)")
            }
            
            let reviewResponse = try JSONDecoder().decode(YelpReviewResponse.self, from: data)
            return reviewResponse.reviews.map { $0.toReview() }
        } catch let error as DecodingError {
            throw YelpError.decodingError(error)
        } catch {
            throw YelpError.networkError(error)
        }
    }
}

// MARK: - Response Models
private struct YelpSearchResponse: Codable {
    let businesses: [YelpBusiness]
    let total: Int
}

private struct YelpBusiness: Codable {
    let id: String
    let name: String
    let imageUrl: String
    let rating: Double
    let reviewCount: Int
    let price: String?
    let categories: [YelpCategory]
    let location: YelpLocation
    let coordinates: YelpCoordinates
    let phone: String
    let distance: Double?
    let hours: [YelpHours]?
    let isClosed: Bool
    
    struct YelpCategory: Codable {
        let alias: String
        let title: String
    }
    
    struct YelpLocation: Codable {
        let address1: String
        let address2: String?
        let address3: String?
        let city: String
        let state: String
        let zipCode: String
        let country: String
        
        enum CodingKeys: String, CodingKey {
            case address1, address2, address3, city, state, country
            case zipCode = "zip_code"
        }
    }
    
    struct YelpCoordinates: Codable {
        let latitude: Double
        let longitude: Double
    }
    
    struct YelpHours: Codable {
        let open: [OpenPeriod]
        let hoursType: String
        let isOpenNow: Bool
        
        struct OpenPeriod: Codable {
            let day: Int
            let start: String
            let end: String
            let isOvernight: Bool
        }
        
        enum CodingKeys: String, CodingKey {
            case open
            case hoursType = "hours_type"
            case isOpenNow = "is_open_now"
        }
    }
    
    func toRestaurant() -> Restaurant {
        let formattedAddress = [
            location.address1,
            location.address2,
            location.address3
        ]
        .compactMap { $0 }
        .filter { !$0.isEmpty }
        .joined(separator: " ")
        + ", \(location.city), \(location.state) \(location.zipCode)"
        
        let priceRange: PriceRange
        if let price = price {
            priceRange = PriceRange(rawValue: price.count) ?? .medium
        } else {
            priceRange = .medium
        }
        
        let openingHours: [Restaurant.OpeningHours]
        if let businessHours = hours?.first?.open {
            openingHours = businessHours.map { period in
                Restaurant.OpeningHours(
                    day: period.day,
                    start: period.start,
                    end: period.end,
                    isOvernight: period.isOvernight
                )
            }
        } else {
            openingHours = []
        }
        
        return Restaurant(
            id: id,
            name: name,
            imageUrl: imageUrl,
            rating: rating,
            reviewCount: reviewCount,
            priceRange: priceRange,
            categories: categories.map(\.title),
            address: formattedAddress,
            coordinates: CLLocationCoordinate2D(
                latitude: coordinates.latitude,
                longitude: coordinates.longitude
            ),
            phone: phone,
            distance: distance ?? 0,
            isOpen: !(hours?.first?.isOpenNow ?? true),
            hours: openingHours
        )
    }
}

private struct YelpReviewResponse: Codable {
    let reviews: [YelpReview]
    let total: Int
    
    struct YelpReview: Codable {
        let id: String
        let rating: Double
        let user: YelpUser
        let text: String
        let timeCreated: String
        let url: String
        
        struct YelpUser: Codable {
            let id: String
            let profileUrl: String?
            let imageUrl: String?
            let name: String
        }
        
        enum CodingKeys: String, CodingKey {
            case id, rating, user, text, url
            case timeCreated = "time_created"
        }
        
        func toReview() -> Review {
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withFullDate, .withTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
            
            return Review(
                id: id,
                rating: rating,
                userName: user.name,
                userImageUrl: user.imageUrl,
                text: text,
                timeCreated: dateFormatter.date(from: timeCreated) ?? Date(),
                url: url
            )
        }
    }
}
