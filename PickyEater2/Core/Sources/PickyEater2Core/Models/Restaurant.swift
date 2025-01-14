import Foundation

public enum PriceRange: String, Codable, CaseIterable {
    case oneDollar = "$"
    case twoDollars = "$$"
    case threeDollars = "$$$"
    case fourDollars = "$$$$"
    case other = "Unknown"

    public var description: String {
        return rawValue
    }
}

public struct AppRestaurant: Codable, Identifiable, Equatable {
    public let id: String
    public let name: String
    public let distance: Double
    public let priceRange: PriceRange
    public let categories: [Category]
    public let imageUrl: String

    public init(id: String, name: String, distance: Double, priceRange: PriceRange, categories: [Category], imageUrl: String) {
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
