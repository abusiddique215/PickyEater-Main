import Foundation

public enum PriceRange: String, Codable {
    case oneDollar = "$"
    case twoDollars = "$$"
    case threeDollars = "$$$"
    case fourDollars = "$$$$"
    case other = "Other"

    public init(from value: String) {
        switch value {
        case "$":
            self = .oneDollar
        case "$$":
            self = .twoDollars
        case "$$$":
            self = .threeDollars
        case "$$$$":
            self = .fourDollars
        default:
            self = .other
        }
    }

    public var rawValueString: String {
        rawValue
    }
}

public struct AppRestaurant: Codable, Identifiable, Equatable {
    public let id: String
    public let name: String
    public let distance: Double?
    public let priceRange: PriceRange
    public let categories: [Category]
    public let imageUrl: String

    public init(
        id: String,
        name: String,
        distance: Double?,
        priceRange: PriceRange,
        categories: [Category],
        imageUrl: String
    ) {
        self.id = id
        self.name = name
        self.distance = distance
        self.priceRange = priceRange
        self.categories = categories
        self.imageUrl = imageUrl
    }

    public static func == (lhs: AppRestaurant, rhs: AppRestaurant) -> Bool {
        lhs.id == rhs.id
    }
}
