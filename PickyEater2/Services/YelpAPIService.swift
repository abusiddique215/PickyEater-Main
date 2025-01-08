import CoreLocation
import Foundation

actor YelpAPIService {
    private let apiKey: String
    private let baseURL = "https://api.yelp.com/v3"
    private let session: URLSession
    private var cache: NSCache<NSString, CacheEntry>
    private let retryPolicy: RetryPolicy

    // MARK: - Cache Implementation

    final class CacheEntry {
        let data: Data
        let timestamp: Date

        init(data: Data, timestamp: Date = Date()) {
            self.data = data
            self.timestamp = timestamp
        }
    }

    struct RetryPolicy {
        let maxRetries: Int
        let baseDelay: TimeInterval
        let maxDelay: TimeInterval

        static let `default` = RetryPolicy(maxRetries: 3, baseDelay: 1.0, maxDelay: 10.0)
    }

    enum YelpError: Error {
        case invalidURL
        case invalidResponse
        case networkError(Error)
        case decodingError(Error)
        case apiError(String)
        case missingAPIKey
        case rateLimitExceeded
        case maxRetriesExceeded

        var localizedDescription: String {
            switch self {
            case .invalidURL:
                return "Invalid URL"
            case .invalidResponse:
                return "Invalid response from server"
            case let .networkError(error):
                return "Network error: \(error.localizedDescription)"
            case let .decodingError(error):
                return "Failed to decode response: \(error.localizedDescription)"
            case let .apiError(message):
                return "API error: \(message)"
            case .missingAPIKey:
                return "Yelp API key is missing"
            case .rateLimitExceeded:
                return "Rate limit exceeded. Please try again later."
            case .maxRetriesExceeded:
                return "Maximum retry attempts exceeded"
            }
        }
    }

    init(
        apiKey: String = ProcessInfo.processInfo.environment["YELP_API_KEY"] ?? "",
        retryPolicy: RetryPolicy = .default,
        cacheSizeLimit: Int = 50 * 1024 * 1024 // 50MB default cache size
    ) {
        self.apiKey = apiKey
        self.retryPolicy = retryPolicy

        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = [
            "Authorization": "Bearer \(apiKey)",
            "Accept": "application/json",
        ]
        config.requestCachePolicy = .returnCacheDataElseLoad
        config.urlCache = URLCache(
            memoryCapacity: 10 * 1024 * 1024, // 10MB memory cache
            diskCapacity: 50 * 1024 * 1024, // 50MB disk cache
            diskPath: "com.pickyeater.yelpcache"
        )

        session = URLSession(configuration: config)
        cache = NSCache<NSString, CacheEntry>()
        cache.countLimit = 100 // Maximum number of cached responses
        cache.totalCostLimit = cacheSizeLimit
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
            location.address3,
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
