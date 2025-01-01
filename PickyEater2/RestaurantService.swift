import Foundation
import CoreLocation
import MapKit

actor RestaurantService {
    static let shared = RestaurantService()
    private let yelpService: YelpAPIService
    
    init() {
        self.yelpService = YelpAPIService(apiKey: Config.yelpAPIKey)
    }
    
    func searchRestaurants(near location: CLLocation, preferences: UserPreferences) async throws -> [Restaurant] {
        print("🔍 Searching for restaurants near: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        
        do {
            // Try Yelp API first
            let radius = Int(preferences.maxDistance * 1000) // Convert km to meters
            let yelpRestaurants = try await yelpService.searchRestaurants(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                radius: radius,
                categories: preferences.cuisinePreferences
            )
            
            let restaurants = yelpRestaurants.map { $0.toRestaurant() }
            
            if restaurants.isEmpty {
                print("⚠️ No restaurants found with Yelp API, trying Apple Maps...")
                return try await searchWithAppleMaps(near: location, preferences: preferences)
            }
            
            return filterRestaurants(restaurants, preferences: preferences)
            
        } catch {
            print("❌ Yelp API error: \(error.localizedDescription)")
            print("↪️ Falling back to Apple Maps...")
            return try await searchWithAppleMaps(near: location, preferences: preferences)
        }
    }
    
    private func searchWithAppleMaps(near location: CLLocation, preferences: UserPreferences) async throws -> [Restaurant] {
        let radius = Int(preferences.maxDistance * 1000)
        let mapItems = try await yelpService.searchWithAppleMaps(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            radius: radius
        )
        
        let restaurants = mapItems.map { $0.toRestaurant() }
        return filterRestaurants(restaurants, preferences: preferences)
    }
    
    private func filterRestaurants(_ restaurants: [Restaurant], preferences: UserPreferences) -> [Restaurant] {
        guard !preferences.cuisinePreferences.isEmpty else { return restaurants }
        
        return restaurants.filter { restaurant in
            let restaurantCuisines = Set(restaurant.categories.map { $0.alias.lowercased() })
            let preferredCuisines = Set(preferences.cuisinePreferences.map { $0.lowercased() })
            return !restaurantCuisines.intersection(preferredCuisines).isEmpty
        }
    }
} 