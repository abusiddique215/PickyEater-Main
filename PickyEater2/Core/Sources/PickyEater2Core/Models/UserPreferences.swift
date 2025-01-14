import Foundation
import SwiftData

@Model
public final class UserPreferences {
    @Attribute(.unique) public var id: String
    @Attribute public var dietaryRestrictionsArray: [String]
    @Attribute public var favoriteCuisinesArray: [String]
    @Attribute public var cravingsArray: [String]
    @Attribute public var latitude: Double?
    @Attribute public var longitude: Double?
    @Attribute public var isSubscribed: Bool
    @Attribute public var sortByRawValue: String
    @Attribute public var maxDistance: Double
    @Attribute public var priceRangeArray: [String]
    @Attribute public var minimumRating: Double
    @Attribute public var maximumDistance: Double
    @Attribute public var cuisinePreferencesData: Data

    public var dietaryRestrictions: Set<DietaryRestriction> {
        get { Set(dietaryRestrictionsArray.compactMap { DietaryRestriction(rawValue: $0) }) }
        set { dietaryRestrictionsArray = Array(newValue.map { $0.rawValue }) }
    }

    public var favoriteCuisines: Set<String> {
        get { Set(favoriteCuisinesArray) }
        set { favoriteCuisinesArray = Array(newValue) }
    }

    public var cravings: Set<String> {
        get { Set(cravingsArray) }
        set { cravingsArray = Array(newValue) }
    }

    public var location: Location? {
        get {
            guard let lat = latitude, let lon = longitude else { return nil }
            return Location(latitude: lat, longitude: lon)
        }
        set {
            latitude = newValue?.latitude
            longitude = newValue?.longitude
        }
    }

    public var sortBy: SortOption {
        get { SortOption(rawValue: sortByRawValue) ?? .bestMatch }
        set { sortByRawValue = newValue.rawValue }
    }

    public var priceRange: Set<PriceRange> {
        get { Set(priceRangeArray.compactMap { PriceRange(rawValue: $0) }) }
        set { priceRangeArray = Array(newValue.map { $0.rawValue }) }
    }

    public var cuisinePreferences: [String: Double] {
        get { (try? JSONDecoder().decode([String: Double].self, from: cuisinePreferencesData)) ?? [:] }
        set { cuisinePreferencesData = (try? JSONEncoder().encode(newValue)) ?? Data() }
    }

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
        dietaryRestrictionsArray = Array(dietaryRestrictions.map { $0.rawValue })
        favoriteCuisinesArray = Array(favoriteCuisines)
        cravingsArray = Array(cravings)
        latitude = location?.latitude
        longitude = location?.longitude
        self.isSubscribed = isSubscribed
        sortByRawValue = sortBy.rawValue
        self.maxDistance = maxDistance
        priceRangeArray = Array(priceRange.map { $0.rawValue })
        self.minimumRating = minimumRating
        self.maximumDistance = maximumDistance
        cuisinePreferencesData = (try? JSONEncoder().encode(cuisinePreferences)) ?? Data()
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
        case rating
        case reviewCount = "review_count"
        case distance

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
