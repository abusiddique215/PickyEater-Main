import Foundation

public final class RestaurantFilterService {
    private var cache: [CacheKey: [Restaurant]] = [:]
    private let pageSize = 20
    
    public init() {}
    
    private struct CacheKey: Hashable {
        let preferences: String
        let location: String
        let page: Int
        
        init(preferences: UserPreferences, location: String, page: Int) {
            self.preferences = "\(preferences.id)_\(preferences.sortBy.rawValue)"
            self.location = location
            self.page = page
        }
    }
    
    public func apply(_ restaurants: [Restaurant], preferences: UserPreferences, page: Int = 0, pageSize: Int = Constants.defaultPageSize) async -> [Restaurant] {
        guard !restaurants.isEmpty else {
            return []
        }
        
        let filteredRestaurants = restaurants.filter { matchesPreferences($0, preferences) }
        let sortedRestaurants = await sortRestaurantsByPreference(filteredRestaurants, preferences)
        
        // Apply pagination
        let startIndex = page * pageSize
        guard startIndex < sortedRestaurants.count else {
            return []
        }
        
        let endIndex = min(startIndex + pageSize, sortedRestaurants.count)
        return Array(sortedRestaurants[startIndex..<endIndex])
    }
    
    private func matchesPreferences(_ restaurant: Restaurant, _ preferences: UserPreferences) -> Bool {
        // Price range check
        if !preferences.priceRange.contains(restaurant.priceRange.rawValue) {
            return false
        }
        
        // Distance check
        if let distance = restaurant.distance, distance > preferences.maximumDistance * 1000 { // Convert km to meters
            return false
        }
        
        // Rating check
        if restaurant.rating < preferences.minimumRating {
            return false
        }
        
        // Dietary restrictions check
        if !preferences.dietaryRestrictions.isEmpty {
            let restaurantCategories = Set(restaurant.categories.map { $0.title.lowercased() })
            let requiredCategories = Set(preferences.dietaryRestrictions.map { $0.rawValue })
            if !requiredCategories.isSubset(of: restaurantCategories) {
                return false
            }
        }
        
        return true
    }
    
    private func sortRestaurantsByPreference(_ restaurants: [Restaurant], _ preferences: UserPreferences) async -> [Restaurant] {
        let restaurantsWithScores = restaurants.map { restaurant in
            (restaurant, calculateScore(restaurant, preferences))
        }
        
        return restaurantsWithScores
            .sorted { $0.1 > $1.1 }
            .map { $0.0 }
    }
    
    private func calculateScore(_ restaurant: Restaurant, _ preferences: UserPreferences) -> Double {
        var score: Double = 0
        
        // Base score from rating (0-50 points)
        score += (restaurant.rating / 5.0) * 50
        
        // Distance score (closer is better)
        if let distance = restaurant.distance {
            let distanceScore = max(0, 1 - (distance / (preferences.maximumDistance * 1000)))
            score += distanceScore * 20
        }
        
        // Price range match (0-10 points)
        if preferences.priceRange.contains(restaurant.priceRange.rawValue) {
            score += 10
        }
        
        // Cuisine preferences
        let categories = restaurant.categories.map { $0.title.lowercased() }
        for category in categories {
            if let preference = preferences.cuisinePreferences[category] {
                score += Double(preference) * 2 // 0-20 points based on preference level (1-10)
            }
        }
        
        return score
    }
}
