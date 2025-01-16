import Foundation

public actor YelpAPIService {
    private let baseURL = URL(string: "https://api.yelp.com/v3/")!
    private let session: URLSession
    
    public init(apiKey: String) {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["Authorization": "Bearer \(apiKey)"]
        self.session = URLSession(configuration: configuration)
    }
    
    public func searchRestaurants(term: String, location: String, categories: [String]? = nil, price: [String]? = nil, openNow: Bool? = nil, sortBy: String? = nil, limit: Int = 20, offset: Int = 0) async throws -> [Restaurant] {
        var queryItems = [
            URLQueryItem(name: "term", value: term),
            URLQueryItem(name: "location", value: location),
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "offset", value: String(offset))
        ]
        
        if let categories = categories {
            queryItems.append(URLQueryItem(name: "categories", value: categories.joined(separator: ",")))
        }
        
        if let price = price {
            queryItems.append(URLQueryItem(name: "price", value: price.joined(separator: ",")))
        }
        
        if let openNow = openNow {
            queryItems.append(URLQueryItem(name: "open_now", value: String(openNow)))
        }
        
        if let sortBy = sortBy {
            queryItems.append(URLQueryItem(name: "sort_by", value: sortBy))
        }
        
        let response: YelpSearchResponse = try await performRequest(endpoint: "businesses/search", queryItems: queryItems)
        return response.businesses.map { $0.toRestaurant() }
    }
    
    public func fetchBusinessDetails(id: String) async throws -> Restaurant {
        let business: YelpBusiness = try await performRequest(endpoint: "businesses/\(id)")
        let reviews = try await fetchReviews(businessId: id)
        var restaurant = business.toRestaurant()
        restaurant.reviews = reviews
        return restaurant
    }
    
    private func fetchReviews(businessId: String) async throws -> [Review] {
        let response: YelpReviewsResponse = try await performRequest(endpoint: "businesses/\(businessId)/reviews")
        return response.reviews.map { review in
            Review(
                id: review.id,
                rating: Int(review.rating),
                text: review.text,
                timeCreated: review.timeCreated,
                user: Review.ReviewUser(
                    id: review.user.id,
                    name: review.user.name
                )
            )
        }
    }
    
    private func performRequest<T: Decodable>(endpoint: String, queryItems: [URLQueryItem] = []) async throws -> T {
        var components = URLComponents(url: baseURL.appendingPathComponent(endpoint), resolvingAgainstBaseURL: true)!
        components.queryItems = queryItems
        
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
}

// MARK: - Response Models
private struct YelpSearchResponse: Codable {
    let businesses: [YelpBusiness]
    let total: Int
}

private struct YelpReviewsResponse: Codable {
    let reviews: [YelpReview]
    let total: Int
    
    enum CodingKeys: String, CodingKey {
        case reviews
        case total
    }
}

extension YelpBusiness {
    func toRestaurant() -> Restaurant {
        let openingHours: Restaurant.OpeningHours? = if let hours = self.hours?.first {
            Restaurant.OpeningHours(
                isOpenNow: hours.isOpenNow,
                hours: hours.open.map { period in
                    Restaurant.OpeningHours.DayHours(
                        day: period.day,
                        start: period.start,
                        end: period.end,
                        isOvernight: period.isOvernight
                    )
                }
            )
        } else {
            nil
        }
        
        return Restaurant(
            id: id,
            name: name,
            distance: distance,
            priceRange: PriceRange(from: price ?? ""),
            rating: rating,
            reviewCount: reviewCount,
            categories: categories.map { category in
                Restaurant.Category(alias: category.alias, title: category.title)
            },
            imageUrl: imageUrl,
            address: location.formattedAddress,
            coordinates: Restaurant.Coordinates(
                latitude: coordinates.latitude,
                longitude: coordinates.longitude
            ),
            phone: phone,
            openingHours: openingHours,
            reviews: [],
            isOpen: hours?.first?.isOpenNow
        )
    }
}
