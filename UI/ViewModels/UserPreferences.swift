struct UserPreferences: Codable, Identifiable {
    // Existing properties...

    func filterRestaurants(_ restaurants: [AppRestaurant]) -> [AppRestaurant] {
        return restaurants.filter { $0.dietaryRestrictions.isSubset(of: dietaryRestrictions) }
    }

    func filterByCategories(_ restaurants: [AppRestaurant], preferredCategories: [String]) -> [AppRestaurant] {
        return restaurants.filter { restaurant in
            return !Set(restaurant.categories.map { $0.title }).intersection(preferredCategories).isEmpty
        }
    }
} 