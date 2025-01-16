import Foundation

// MARK: - Restaurant Model
public struct Restaurant: Identifiable, Codable, Hashable {
    public let id: String
    public let name: String
    public let distance: Double?
    public let priceRange: PriceRange
    public let rating: Double
    public let reviewCount: Int
    public let categories: [Category]
    public let imageUrl: String?
    public let address: String
    public let coordinates: Coordinates
    public let phone: String?
    public let openingHours: OpeningHours?
    public var reviews: [Review]
    public let isOpen: Bool?
    
    public init(
        id: String,
        name: String,
        distance: Double?,
        priceRange: PriceRange,
        rating: Double,
        reviewCount: Int,
        categories: [Category],
        imageUrl: String?,
        address: String,
        coordinates: Coordinates,
        phone: String?,
        openingHours: OpeningHours?,
        reviews: [Review],
        isOpen: Bool?
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
    
    // MARK: - Hashable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Restaurant, rhs: Restaurant) -> Bool {
        lhs.id == rhs.id
    }
    
    // MARK: - Codable
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case distance
        case priceRange = "price"
        case rating
        case reviewCount = "review_count"
        case categories
        case imageUrl = "image_url"
        case address = "formatted_address"
        case coordinates
        case phone
        case openingHours = "hours"
        case reviews
        case isOpen = "is_open"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Required fields
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        rating = try container.decode(Double.self, forKey: .rating)
        reviewCount = try container.decode(Int.self, forKey: .reviewCount)
        categories = try container.decode([Category].self, forKey: .categories)
        address = try container.decode(String.self, forKey: .address)
        coordinates = try container.decode(Coordinates.self, forKey: .coordinates)
        
        // Optional fields
        distance = try container.decodeIfPresent(Double.self, forKey: .distance)
        let priceString = try container.decodeIfPresent(String.self, forKey: .priceRange)
        priceRange = PriceRange(from: priceString ?? "")
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        phone = try container.decodeIfPresent(String.self, forKey: .phone)
        openingHours = try container.decodeIfPresent(OpeningHours.self, forKey: .openingHours)
        reviews = try container.decodeIfPresent([Review].self, forKey: .reviews) ?? []
        isOpen = try container.decodeIfPresent(Bool.self, forKey: .isOpen)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Required fields
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(rating, forKey: .rating)
        try container.encode(reviewCount, forKey: .reviewCount)
        try container.encode(categories, forKey: .categories)
        try container.encode(address, forKey: .address)
        try container.encode(coordinates, forKey: .coordinates)
        
        // Optional fields
        try container.encodeIfPresent(distance, forKey: .distance)
        try container.encode(priceRange.rawValue, forKey: .priceRange)
        try container.encodeIfPresent(imageUrl, forKey: .imageUrl)
        try container.encodeIfPresent(phone, forKey: .phone)
        try container.encodeIfPresent(openingHours, forKey: .openingHours)
        try container.encode(reviews, forKey: .reviews)
        try container.encodeIfPresent(isOpen, forKey: .isOpen)
    }
    
    public struct Category: Codable, Hashable {
        public let alias: String
        public let title: String
        
        public init(alias: String, title: String) {
            self.alias = alias
            self.title = title
        }
    }
    
    public struct Coordinates: Codable, Hashable {
        public let latitude: Double
        public let longitude: Double
        
        public init(latitude: Double, longitude: Double) {
            self.latitude = latitude
            self.longitude = longitude
        }
    }
    
    public struct OpeningHours: Codable, Hashable {
        public let isOpenNow: Bool
        public let hours: [DayHours]
        
        public init(isOpenNow: Bool, hours: [DayHours]) {
            self.isOpenNow = isOpenNow
            self.hours = hours
        }
        
        public struct DayHours: Codable, Hashable {
            public let day: Int
            public let start: String
            public let end: String
            public let isOvernight: Bool
            
            public init(day: Int, start: String, end: String, isOvernight: Bool) {
                self.day = day
                self.start = start
                self.end = end
                self.isOvernight = isOvernight
            }
        }
    }
} 