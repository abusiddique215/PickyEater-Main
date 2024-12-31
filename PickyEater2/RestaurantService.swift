import Foundation
import CoreLocation

// Import our models
@_exported import Models

actor RestaurantService {
    static let shared = RestaurantService()
    private let yelpService: YelpAPIService
    
    init() {
        self.yelpService = YelpAPIService(apiKey: Config.yelpAPIKey)
    }
    
    func searchRestaurants(near location: CLLocation, preferences: UserPreferences) async throws -> [Restaurant] {
        let radius = Int(preferences.maxDistance * 1000) // Convert km to meters
        let yelpRestaurants = try await yelpService.searchRestaurants(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            radius: radius,
            categories: preferences.cuisinePreferences
        )
        
        return yelpRestaurants.map { $0.toRestaurant() }
            .filter { restaurant in
                // Filter based on user preferences
                if !preferences.cuisinePreferences.isEmpty {
                    let restaurantCuisines = Set(restaurant.categories.map { $0.alias.lowercased() })
                    let preferredCuisines = Set(preferences.cuisinePreferences.map { $0.lowercased() })
                    if !restaurantCuisines.intersection(preferredCuisines).isEmpty {
                        return true
                    }
                    return false
                }
                return true
            }
    }
} 