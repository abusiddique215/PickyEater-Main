import Foundation
import SwiftData

@Model
public final class UserPreferences {
    public var id: String
    public var dietaryRestrictions: Set<DietaryRestriction>
    public var favoriteCuisines: Set<String>
    public var cravings: Set<String>
    public var location: Location?
    public var isSubscribed: Bool
    public var sortBy: SortOption
    public var maxDistance: Double
    public var priceRange: Set<PriceRange>
    public var minimumRating: Double
    public var maximumDistance: Double
    public var cuisinePreferences: [String: Double]
    
    public init(
        id: String = UUID().uuidString,
        dietaryRestrictions: Set<DietaryRestriction> = [],
        favoriteCuisines: Set<String> = [],
        cravings: Set<String> = [],
        location: Location? = nil,
        isSubscribed: Bool = false,
        sortBy: SortOption = .bestMatch,
        maxDistance: Double = 5.0,
        priceRange: Set<PriceRange> = [.oneDollar, .twoDollars],
        minimumRating: Double = 4.0,
        maximumDistance: Double = 10.0,
        cuisinePreferences: [String: Double] = [:]
    ) {
        self.id = id
        self.dietaryRestrictions = dietaryRestrictions
        self.favoriteCuisines = favoriteCuisines
        self.cravings = cravings
        self.location = location
        self.isSubscribed = isSubscribed
        self.sortBy = sortBy
        self.maxDistance = maxDistance
        self.priceRange = priceRange
        self.minimumRating = minimumRating
        self.maximumDistance = maximumDistance
        self.cuisinePreferences = cuisinePreferences
    }
    
    public struct Location: Codable, Equatable {
        public let latitude: Double
        public let longitude: Double
        
        public init(latitude: Double, longitude: Double) {
            self.latitude = latitude
            self.longitude = longitude
        }
    }
    
    public enum SortOption: String, Codable, CaseIterable {
        case bestMatch = "best_match"
        case rating = "rating"
        case reviewCount = "review_count"
        case distance = "distance"
        
        public var description: String {
            switch self {
            case .bestMatch:
                return "Best Match"
            case .rating:
                return "Rating"
            case .reviewCount:
                return "Review Count"
            case .distance:
                return "Distance"
            }
        }
    }
}
