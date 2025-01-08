import Foundation
import Combine

class RestaurantFilterService {
    private let preferencesManager: PreferencesManager
    
    init(preferencesManager: PreferencesManager) {
        self.preferencesManager = preferencesManager
    }
    
    func filterRestaurants(_ restaurants: [Restaurant], preferences: UserPreferences) -> [Restaurant] {
        return restaurants.filter { restaurant in
            var matches = true
            
            // Price range filter
            if let pricePreference = preferences.priceRange {
                matches = matches && (restaurant.priceRange <= pricePreference)
            }
            
            // Dietary restrictions filter
            if !preferences.dietaryRestrictions.isEmpty {
                let restaurantCategories = restaurant.categories.map { $0.lowercased() }
                matches = matches && preferences.dietaryRestrictions.allSatisfy { restriction in
                    switch restriction {
                    case .vegetarian:
                        return restaurantCategories.contains("vegetarian")
                    case .vegan:
                        return restaurantCategories.contains("vegan")
                    case .glutenFree:
                        return restaurantCategories.contains("gluten-free")
                    case .dairyFree:
                        return restaurantCategories.contains("dairy-free")
                    }
                }
            }
            
            // Cuisine preferences filter
            if !preferences.cuisinePreferences.isEmpty {
                let restaurantCuisines = Set(restaurant.categories.map { $0.lowercased() })
                let preferredCuisines = Set(preferences.cuisinePreferences.map { $0.lowercased() })
                matches = matches && !restaurantCuisines.isDisjoint(with: preferredCuisines)
            }
            
            // Rating filter
            if let minRating = preferences.minimumRating {
                matches = matches && (restaurant.rating >= minRating)
            }
            
            // Distance filter
            if let maxDistance = preferences.maximumDistance {
                matches = matches && (restaurant.distance <= maxDistance)
            }
            
            return matches
        }
    }
    
    func calculateMatchScore(_ restaurant: Restaurant, preferences: UserPreferences) -> Double {
        var score = 0.0
        let maxScore = 100.0
        
        // Price match (20 points)
        if let pricePreference = preferences.priceRange {
            score += (1.0 - Double(abs(Int(restaurant.priceRange.rawValue) - Int(pricePreference.rawValue))) / 3.0) * 20
        }
        
        // Dietary restrictions match (30 points)
        if !preferences.dietaryRestrictions.isEmpty {
            let restaurantCategories = restaurant.categories.map { $0.lowercased() }
            let matchingRestrictions = preferences.dietaryRestrictions.filter { restriction in
                restaurantCategories.contains(restriction.description.lowercased())
            }
            score += Double(matchingRestrictions.count) / Double(preferences.dietaryRestrictions.count) * 30
        }
        
        // Cuisine preferences match (25 points)
        if !preferences.cuisinePreferences.isEmpty {
            let restaurantCuisines = Set(restaurant.categories.map { $0.lowercased() })
            let preferredCuisines = Set(preferences.cuisinePreferences.map { $0.lowercased() })
            let matchingCuisines = restaurantCuisines.intersection(preferredCuisines)
            score += Double(matchingCuisines.count) / Double(preferences.cuisinePreferences.count) * 25
        }
        
        // Rating match (15 points)
        if let minRating = preferences.minimumRating {
            score += (restaurant.rating >= minRating ? 15 : (restaurant.rating / minRating) * 15)
        }
        
        // Distance match (10 points)
        if let maxDistance = preferences.maximumDistance {
            score += (1.0 - min(restaurant.distance / maxDistance, 1.0)) * 10
        }
        
        return min(score, maxScore)
    }
    
    func sortRestaurantsByPreference(_ restaurants: [Restaurant], preferences: UserPreferences) -> [Restaurant] {
        return restaurants.sorted { first, second in
            calculateMatchScore(first, preferences: preferences) > calculateMatchScore(second, preferences: preferences)
        }
    }
} 