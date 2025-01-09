import Foundation

struct UserPreferences: Codable, Identifiable {
    let id: UUID
    var dietaryRestrictions: Set<DietaryRestriction>
    var favoriteCuisines: [String]
    var cravings: String
    var location: String
    var isSubscribed: Bool
    var sortBy: SortOption

    enum SortOption: String, Codable {
        case name
        case distance
        case rating
    }

    // Additional initializers and methods if necessary

    func filterRestaurants(_ restaurants: [AppRestaurant]) -> [AppRestaurant] {
        // Filtering logic...
    }

    func filterByCategories(_ restaurants: [AppRestaurant], preferredCategories: [String]) -> [AppRestaurant] {
        // Filtering logic...
    }
}
