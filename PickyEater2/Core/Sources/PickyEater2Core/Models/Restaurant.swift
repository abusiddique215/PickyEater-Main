import Foundation

public struct Restaurant: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let distance: Double
    public let priceRange: PriceRange
    public let rating: Double
    public let reviewCount: Int
    public let categories: [String]
    public let imageUrl: URL?
    public let address: String
    public let coordinates: Coordinates
    public let phone: String
    public let openingHours: [OpeningHours]
    public let reviews: [Review]
    public let isOpen: Bool
    
    public struct Coordinates: Codable, Hashable, Sendable {
        public let latitude: Double
        public let longitude: Double
        
        public init(latitude: Double, longitude: Double) {
            self.latitude = latitude
            self.longitude = longitude
        }
        
        enum CodingKeys: String, CodingKey {
            case latitude
            case longitude
        }
    }
    
    public struct OpeningHours: Codable, Hashable, Sendable {
        public let day: Int
        public let start: String
        public let end: String
        
        public init(day: Int, start: String, end: String) {
            self.day = day
            self.start = start
            self.end = end
        }
        
        enum CodingKeys: String, CodingKey {
            case day
            case start
            case end
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case distance
        case priceRange = "price"
        case rating
        case reviewCount = "review_count"
        case categories
        case imageUrl = "image_url"
        case address
        case coordinates
        case phone
        case openingHours = "hours"
        case reviews
        case isOpen = "is_open"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        distance = try container.decode(Double.self, forKey: .distance)
        priceRange = try container.decode(PriceRange.self, forKey: .priceRange)
        rating = try container.decode(Double.self, forKey: .rating)
        reviewCount = try container.decode(Int.self, forKey: .reviewCount)
        categories = try container.decode([String].self, forKey: .categories)
        imageUrl = try container.decodeIfPresent(URL.self, forKey: .imageUrl)
        address = try container.decode(String.self, forKey: .address)
        coordinates = try container.decode(Coordinates.self, forKey: .coordinates)
        phone = try container.decode(String.self, forKey: .phone)
        openingHours = try container.decode([OpeningHours].self, forKey: .openingHours)
        reviews = try container.decode([Review].self, forKey: .reviews)
        isOpen = try container.decode(Bool.self, forKey: .isOpen)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(distance, forKey: .distance)
        try container.encode(priceRange, forKey: .priceRange)
        try container.encode(rating, forKey: .rating)
        try container.encode(reviewCount, forKey: .reviewCount)
        try container.encode(categories, forKey: .categories)
        try container.encode(imageUrl, forKey: .imageUrl)
        try container.encode(address, forKey: .address)
        try container.encode(coordinates, forKey: .coordinates)
        try container.encode(phone, forKey: .phone)
        try container.encode(openingHours, forKey: .openingHours)
        try container.encode(reviews, forKey: .reviews)
        try container.encode(isOpen, forKey: .isOpen)
    }
    
    public init(
        id: String,
        name: String,
        distance: Double,
        priceRange: PriceRange,
        rating: Double,
        reviewCount: Int,
        categories: [String],
        imageUrl: URL?,
        address: String,
        coordinates: Coordinates,
        phone: String,
        openingHours: [OpeningHours],
        reviews: [Review],
        isOpen: Bool
    ) {
        self.id = id
        self.name = name
        self.distance = distance
        self.priceRange = priceRange
        self.rating = rating
        self.reviewCount = reviewCount
        self.categories = categories
        self.imageUrl = imageUrl
        self.address = address
        self.coordinates = coordinates
        self.phone = phone
        self.openingHours = openingHours
        self.reviews = reviews
        self.isOpen = isOpen
    }
} 