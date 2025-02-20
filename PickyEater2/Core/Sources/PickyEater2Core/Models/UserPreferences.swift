import Foundation
import SwiftData

@Model
public final class UserPreferences {
    @Attribute(.unique) public var id: String
    public var dietaryRestrictionsArray: [String]
    public var favoriteCuisinesArray: [String]
    public var cravingsArray: [String]
    public var latitude: Double?
    public var longitude: Double?
    public var isSubscribed: Bool
    public var sortByRawValue: String
    public var maxDistance: Double
    public var priceRangeArray: [String]
    public var minimumRating: Double
    public var maximumDistance: Double
    public var cuisinePreferencesData: [String: Double]
    
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
            guard let latitude = latitude, let longitude = longitude else { return nil }
            return Location(latitude: latitude, longitude: longitude)
        }
        set {
            latitude = newValue?.latitude
            longitude = newValue?.longitude
        }
    }
    
    public var sortBy: SortOption {
        get { SortOption(rawValue: sortByRawValue) ?? .distance }
        set { sortByRawValue = newValue.rawValue }
    }
    
    public var priceRange: Set<String> {
        get { Set(priceRangeArray) }
        set { priceRangeArray = Array(newValue) }
    }
    
    public var cuisinePreferences: [String: Double] {
        get { cuisinePreferencesData }
        set { cuisinePreferencesData = newValue }
    }
    
    public init(
        id: String = UUID().uuidString,
        dietaryRestrictions: Set<DietaryRestriction> = [],
        favoriteCuisines: Set<String> = [],
        cravings: Set<String> = [],
        location: Location? = nil,
        isSubscribed: Bool = false,
        sortBy: SortOption = .distance,
        maxDistance: Double = 10.0,
        priceRange: Set<String> = [],
        minimumRating: Double = 0.0,
        maximumDistance: Double = 50.0,
        cuisinePreferences: [String: Double] = [:]
    ) {
        self.id = id
        self.dietaryRestrictionsArray = Array(dietaryRestrictions.map { $0.rawValue })
        self.favoriteCuisinesArray = Array(favoriteCuisines)
        self.cravingsArray = Array(cravings)
        self.latitude = location?.latitude
        self.longitude = location?.longitude
        self.isSubscribed = isSubscribed
        self.sortByRawValue = sortBy.rawValue
        self.maxDistance = maxDistance
        self.priceRangeArray = Array(priceRange)
        self.minimumRating = minimumRating
        self.maximumDistance = maximumDistance
        self.cuisinePreferencesData = cuisinePreferences
    }
}

extension UserPreferences {
    public struct Location: Codable, Hashable {
        public var latitude: Double
        public var longitude: Double
        
        public init(latitude: Double, longitude: Double) {
            self.latitude = latitude
            self.longitude = longitude
        }
    }
    
    public enum SortOption: String, Codable, CaseIterable {
        case distance
        case rating
        case reviewCount = "review_count"
        case bestMatch = "best_match"
    }
} 