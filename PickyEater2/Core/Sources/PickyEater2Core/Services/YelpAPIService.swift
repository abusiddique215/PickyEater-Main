import CoreLocation
import Foundation

public actor YelpAPIService {
    private let apiKey: String
    private let baseURL = "https://api.yelp.com/v3"
    private let session: URLSession
    private let cache: NSCache<NSString, CacheEntry>
    private let retryPolicy: RetryPolicy
    
    public struct RetryPolicy: Sendable {
        public let maxRetries: Int
        public let baseDelay: TimeInterval
        public let maxDelay: TimeInterval
        
        public static let `default` = RetryPolicy(maxRetries: 3, baseDelay: 1.0, maxDelay: 10.0)
        
        public init(maxRetries: Int, baseDelay: TimeInterval, maxDelay: TimeInterval) {
            self.maxRetries = maxRetries
            self.baseDelay = baseDelay
            self.maxDelay = maxDelay
        }
    }
    
    private final class CacheEntry {
        let data: Data
        let timestamp: Date
        
        init(data: Data, timestamp: Date = Date()) {
            self.data = data
            self.timestamp = timestamp
        }
    }
    
    public init(
        apiKey: String = ProcessInfo.processInfo.environment["YELP_API_KEY"] ?? "",
        retryPolicy: RetryPolicy = .default,
        cacheSizeLimit: Int = 100
    ) {
        self.apiKey = apiKey
        self.retryPolicy = retryPolicy
        
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .returnCacheDataElseLoad
        config.urlCache = URLCache(memoryCapacity: 50 * 1024 * 1024, diskCapacity: 100 * 1024 * 1024)
        
        self.session = URLSession(configuration: config)
        self.cache = NSCache<NSString, CacheEntry>()
        self.cache.countLimit = cacheSizeLimit
    }

    // MARK: - Public Methods

    func searchRestaurants(
        location: CLLocation,
        term: String? = nil,
        categories: [String]? = nil,
        price: PriceRange? = nil,
        radius: Int? = nil,
        limit: Int = 20,
        offset: Int = 0,
        sortBy: String = "best_match",
        forceRefresh: Bool = false
    ) async throws -> [Restaurant] {
        guard !apiKey.isEmpty else {
            throw YelpError.missingAPIKey
        }

        let components = try buildURLComponents(
            endpoint: "businesses/search",
            parameters: [
                "latitude": String(location.coordinate.latitude),
                "longitude": String(location.coordinate.longitude),
                "limit": String(limit),
                "offset": String(offset),
                "sort_by": sortBy,
                "term": term,
                "categories": categories?.joined(separator: ","),
                "price": price.map { String($0.rawValue) },
                "radius": radius.map { String($0) },
            ].compactMapValues { $0 }
        )

        return try await performRequest(
            with: components,
            responseType: YelpSearchResponse.self,
            forceRefresh: forceRefresh
        ).businesses.map { $0.toRestaurant() }
    }

    func fetchRestaurantDetails(
        id: String,
        forceRefresh: Bool = false
    ) async throws -> Restaurant {
        guard !apiKey.isEmpty else {
            throw YelpError.missingAPIKey
        }

        let components = try buildURLComponents(endpoint: "businesses/\(id)")

        return try await performRequest(
            with: components,
            responseType: YelpBusiness.self,
            forceRefresh: forceRefresh
        ).toRestaurant()
    }

    func fetchReviews(
        for id: String,
        forceRefresh: Bool = false
    ) async throws -> [Review] {
        guard !apiKey.isEmpty else {
            throw YelpError.missingAPIKey
        }

        let components = try buildURLComponents(endpoint: "businesses/\(id)/reviews")

        return try await performRequest(
            with: components,
            responseType: YelpReviewResponse.self,
            forceRefresh: forceRefresh
        ).reviews.map { $0.toReview() }
    }

    public func fetchBusinessDetails(id: String) async throws -> Restaurant {
        let url = URL(string: "\(baseURL)/businesses/\(id)")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let business = try JSONDecoder().decode(YelpBusiness.self, from: data)
        return mapYelpBusinessToRestaurant(business)
    }

    // MARK: - Cache Management

    func clearCache() {
        cache.removeAllObjects()
    }

    // MARK: - Private Methods

    private func buildURLComponents(
        endpoint: String,
        parameters: [String: String] = [:]
    ) throws -> URLComponents {
        guard var components = URLComponents(string: "\(baseURL)/\(endpoint)") else {
            throw YelpError.invalidURL
        }

        if !parameters.isEmpty {
            components.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        }

        return components
    }

    private func performRequest<T: Decodable>(
        with components: URLComponents,
        responseType: T.Type,
        forceRefresh: Bool,
        retryCount: Int = 0
    ) async throws -> T {
        guard let url = components.url else {
            throw YelpError.invalidURL
        }

        let cacheKey = NSString(string: url.absoluteString)

        // Check cache if not forcing refresh
        if !forceRefresh, let cachedEntry = cache.object(forKey: cacheKey) {
            // Cache is valid for 30 minutes
            if Date().timeIntervalSince(cachedEntry.timestamp) < 1800 {
                return try JSONDecoder().decode(T.self, from: cachedEntry.data)
            }
        }

        do {
            let (data, response) = try await session.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw YelpError.invalidResponse
            }

            switch httpResponse.statusCode {
            case 200:
                // Cache successful response
                cache.setObject(CacheEntry(data: data), forKey: cacheKey)
                return try JSONDecoder().decode(T.self, from: data)

            case 429:
                throw YelpError.rateLimitExceeded

            case 500 ... 599:
                // Retry on server errors if within retry policy
                if retryCount < retryPolicy.maxRetries {
                    let delay = min(
                        retryPolicy.baseDelay * pow(2.0, Double(retryCount)),
                        retryPolicy.maxDelay
                    )
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    return try await performRequest(
                        with: components,
                        responseType: responseType,
                        forceRefresh: forceRefresh,
                        retryCount: retryCount + 1
                    )
                }
                throw YelpError.maxRetriesExceeded

            default:
                throw YelpError.apiError("HTTP \(httpResponse.statusCode)")
            }
        } catch let error as YelpError {
            throw error
        } catch let error as DecodingError {
            throw YelpError.decodingError(error)
        } catch {
            throw YelpError.networkError(error)
        }
    }

    private func mapYelpBusinessToRestaurant(_ business: YelpBusiness) -> Restaurant {
        let priceRange = if let price = business.price {
            PriceRange(rawValue: price.count)
        } else {
            PriceRange.unknown
        }
        
        let openingHours: [Restaurant.OpeningHours] = business.hours?.first?.open.map { period in
            Restaurant.OpeningHours(
                day: period.day,
                start: period.start,
                end: period.end
            )
        } ?? []
        
        return Restaurant(
            id: business.id,
            name: business.name,
            distance: business.distance ?? 0,
            priceRange: priceRange,
            rating: business.rating,
            reviewCount: business.reviewCount,
            categories: business.categories.map(\.title),
            imageUrl: business.imageUrl.flatMap { URL(string: $0) },
            address: business.location.formattedAddress,
            coordinates: Restaurant.Coordinates(
                latitude: business.coordinates.latitude,
                longitude: business.coordinates.longitude
            ),
            phone: business.phone ?? "",
            openingHours: openingHours,
            reviews: [],
            isOpen: !(business.hours?.first?.isOpenNow ?? false)
        )
    }

    private func mapYelpReviewToReview(_ review: YelpReviewResponse.YelpReview) -> Review {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        return Review(
            id: review.id,
            rating: review.rating,
            text: review.text,
            timeCreated: dateFormatter.date(from: review.timeCreated) ?? Date(),
            user: Review.ReviewUser(
                id: review.user.id,
                name: review.user.name
            )
        )
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
    let distance: Double?
    let price: String?
    let rating: Double
    let reviewCount: Int
    let categories: [Category]
    let imageUrl: String?
    let location: YelpLocation
    let coordinates: YelpCoordinates
    let phone: String?
    let hours: [Hours]?
    
    struct Category: Codable {
        let title: String
    }
    
    struct YelpLocation: Codable {
        let address1: String?
        let address2: String?
        let address3: String?
        let city: String
        let state: String
        let zipCode: String
        let country: String
        
        var formattedAddress: String {
            var components = [String]()
            if let address1 = address1 { components.append(address1) }
            if let address2 = address2 { components.append(address2) }
            if let address3 = address3 { components.append(address3) }
            components.append("\(city), \(state) \(zipCode)")
            return components.joined(separator: ", ")
        }
        
        enum CodingKeys: String, CodingKey {
            case address1, address2, address3, city, state
            case zipCode = "zip_code"
            case country
        }
    }
    
    struct YelpCoordinates: Codable {
        let latitude: Double
        let longitude: Double
    }
    
    struct Hours: Codable {
        let isOpenNow: Bool
        let open: [Period]
        
        enum CodingKeys: String, CodingKey {
            case isOpenNow = "is_open_now"
            case open
        }
    }
    
    struct Period: Codable {
        let day: Int
        let start: String
        let end: String
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, distance, price, rating
        case reviewCount = "review_count"
        case categories, imageUrl, location, coordinates, phone, hours
    }

    func toRestaurant() -> Restaurant {
        let formattedAddress = [
            location.address1,
            location.address2,
            location.address3,
        ]
        .compactMap { $0 }
        .filter { !$0.isEmpty }
        .joined(separator: " ")
        + ", \(location.city), \(location.state) \(location.zipCode)"

        let priceRange = if let price = price {
            PriceRange(rawValue: price.count)
        } else {
            PriceRange.unknown
        }

        let openingHours: [Restaurant.OpeningHours] = hours?.first?.open.map { period in
            Restaurant.OpeningHours(
                day: period.day,
                start: period.start,
                end: period.end
            )
        } ?? []

        return Restaurant(
            id: id,
            name: name,
            distance: distance ?? 0,
            priceRange: priceRange,
            rating: rating,
            reviewCount: reviewCount,
            categories: categories.map(\.title),
            imageUrl: imageUrl.flatMap { URL(string: $0) },
            address: formattedAddress,
            coordinates: Restaurant.Coordinates(
                latitude: coordinates.latitude,
                longitude: coordinates.longitude
            ),
            phone: phone ?? "",
            openingHours: openingHours,
            reviews: [],
            isOpen: !(hours?.first?.isOpenNow ?? false)
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
                text: text,
                timeCreated: dateFormatter.date(from: timeCreated) ?? Date(),
                user: Review.ReviewUser(
                    id: user.id,
                    name: user.name
                )
            )
        }
    }
}
