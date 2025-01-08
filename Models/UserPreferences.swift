import SwiftUI
import SwiftData

@Model
final class UserPreferences {
    var maxDistance: Int
    var priceRange: Int
    var dietaryRestrictionsData: Data
    var cuisinePreferencesData: Data
    var theme: AppTheme
    
    var dietaryRestrictions: [String] {
        get { decodeArray(from: dietaryRestrictionsData) }
        set { dietaryRestrictionsData = encodeArray(newValue) }
    }
    
    var cuisinePreferences: [String] {
        get { decodeArray(from: cuisinePreferencesData) }
        set { cuisinePreferencesData = encodeArray(newValue) }
    }
    
    init(
        maxDistance: Int = 5,
        priceRange: Int = 2,
        dietaryRestrictions: [String] = [],
        cuisinePreferences: [String] = [],
        theme: AppTheme = .system
    ) {
        self.maxDistance = maxDistance
        self.priceRange = priceRange
        self.theme = theme
        self.dietaryRestrictionsData = Data()
        self.cuisinePreferencesData = Data()
        self.dietaryRestrictions = dietaryRestrictions
        self.cuisinePreferences = cuisinePreferences
    }

    private func encodeArray(_ array: [String]) -> Data {
        (try? JSONEncoder().encode(array)) ?? Data()
    }

    private func decodeArray(from data: Data) -> [String] {
        (try? JSONDecoder().decode([String].self, from: data)) ?? []
    }

    // Example filter function using priceRange and distance
    func filterRestaurants(_ restaurants: [Restaurant]) -> [Restaurant] {
        restaurants.filter { restaurant in
            guard let distance = restaurant.distance else { return false }
            return distance <= Double(maxDistance) &&
                   restaurant.priceRange.rawValue <= priceRange
        }
    }
    
    // If you have another filter related to categories
    func filterByCategories(_ restaurants: [Restaurant], preferredCategories: [String]) -> [Restaurant] {
        restaurants.filter { restaurant in
            let restaurantCategories = Set(restaurant.categories.map { $0.alias.lowercased() })
            let preferred = Set(preferredCategories.map { $0.lowercased() })
            return !restaurantCategories.isDisjoint(with: preferred)
        }
    }
} 