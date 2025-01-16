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
    
    public func filterRestaurants(
        _ restaurants: [Restaurant],
        preferences: UserPreferences,
        location: String,
        page: Int = 0,
        useCache: Bool = true
    ) async -> [Restaurant] {
        let cacheKey = CacheKey(preferences: preferences, location: location, page: page)
        
        if useCache, let cachedResults = cache[cacheKey] {
            return cachedResults
        }
        
        let filteredRestaurants = restaurants.filter { matchesPreferences($0, preferences: preferences) }
        let sortedRestaurants = await sortRestaurantsByPreference(filteredRestaurants, preferences: preferences)
        
        let startIndex = page * pageSize
        let endIndex = min(startIndex + pageSize, sortedRestaurants.count)
        guard startIndex < sortedRestaurants.count else { return [] }
        
        let pagedResults = Array(sortedRestaurants[startIndex..<endIndex])
        if useCache {
            cache[cacheKey] = pagedResults
        }
        
        return pagedResults
    }
    
    private func matchesPreferences(_ restaurant: Restaurant, preferences: UserPreferences) -> Bool {
        // Price range check
        if !preferences.priceRange.isEmpty {
            guard preferences.priceRange.contains(restaurant.priceRange.rawValue) else { return false }
        }
        
        // Rating check
        if restaurant.rating < preferences.minimumRating {
            return false
        }
        
        // Distance check
        if restaurant.distance > preferences.maximumDistance * 1000 { // Convert km to meters
            return false
        }
        
        // Dietary restrictions check
        if !preferences.dietaryRestrictions.isEmpty {
            let restaurantCategories = Set(restaurant.categories.map { $0.lowercased() })
            let requiredCategories = Set(preferences.dietaryRestrictions.map { $0.rawValue })
            if !requiredCategories.isSubset(of: restaurantCategories) {
                return false
            }
        }
        
        return true
    }
    
    private func sortRestaurantsByPreference(_ restaurants: [Restaurant], preferences: UserPreferences) async -> [Restaurant] {
        let restaurantsWithScores = restaurants.map { restaurant in
            (restaurant, calculateMatchScore(restaurant, preferences: preferences))
        }
        
        return restaurantsWithScores
            .sorted { $0.1 > $1.1 }
            .map { $0.0 }
    }
    
    private func calculateMatchScore(_ restaurant: Restaurant, preferences: UserPreferences) -> Double {
        var score = 0.0
        let maxScore = 100.0
        
        // Base score from rating
        score += (restaurant.rating / 5.0) * 30
        
        // Distance score (closer is better)
        let distanceScore = max(0, 1 - (restaurant.distance / (preferences.maximumDistance * 1000)))
        score += distanceScore * 20
        
        // Price range match
        if preferences.priceRange.contains(restaurant.priceRange.rawValue) {
            score += 20
        }
        
        // Cuisine preferences
        let categories = restaurant.categories.map { $0.lowercased() }
        for category in categories {
            if let preference = preferences.cuisinePreferences[category] {
                score += preference * 30 / Double(categories.count)
            }
        }
        
        return min(score, maxScore)
    }
}
