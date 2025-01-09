struct UserPreferences: Codable, Identifiable {
    // Existing properties...

    func filterRestaurants(_ restaurants: [AppRestaurant]) -> [AppRestaurant] {
        restaurants.filter { $0.dietaryRestrictions.isSubset(of: dietaryRestrictions) }
    }

    func filterByCategories(_ restaurants: [AppRestaurant], preferredCategories: [String]) -> [AppRestaurant] {
        restaurants.filter { restaurant in
            !Set(restaurant.categories.map(\.title)).intersection(preferredCategories).isEmpty
        }
    }
}
