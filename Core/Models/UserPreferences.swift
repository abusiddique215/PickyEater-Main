import Foundation

struct UserPreferences: Codable, Identifiable {
    let id: UUID
    var dietaryRestrictions: Set<DietaryRestriction>
    var favoriteCuisines: [String]
    var cravings: String
    var location: String
    var isSubscribed: Bool
    var sortBy: SortOption
    var maxDistance: Double
    var priceRange: PriceRange?
    var minimumRating: Double?
    var maximumDistance: Double?
    var cuisinePreferences: Set<String>

    enum SortOption: String, Codable {
        case name
        case distance
        case rating
        case bestMatch
        case reviewCount
    }

    init(
        id: UUID = UUID(),
        dietaryRestrictions: Set<DietaryRestriction> = [],
        favoriteCuisines: [String] = [],
        cravings: String = "",
        location: String = "",
        isSubscribed: Bool = false,
        sortBy: SortOption = .name,
        maxDistance: Double = 5.0,
        priceRange: PriceRange? = nil,
        minimumRating: Double? = nil,
        maximumDistance: Double? = nil,
        cuisinePreferences: Set<String> = []
    ) {
        self.id = id
        self.dietaryRestrictions = dietaryRestrictions
        self.favoriteCuisines = favoriteCuisines
        self.cravings = cravings
        self.location = location
        self.isSubscribed = isSubscribed
        self.sortBy = sortBy
        self.maxDistance = maxDistance
        self.priceRange = priceRange
        self.minimumRating = minimumRating
        self.maximumDistance = maximumDistance
        self.cuisinePreferences = cuisinePreferences
    }

    func filterRestaurants(_ restaurants: [AppRestaurant]) -> [AppRestaurant] {
        restaurants.filter { restaurant in
            // Add your filtering logic here
            true // Placeholder
        }
    }

    mutating func toggleDietaryRestriction(_ restriction: DietaryRestriction) {
        if dietaryRestrictions.contains(restriction) {
            dietaryRestrictions.remove(restriction)
        } else {
            dietaryRestrictions.insert(restriction)
        }
    }

    mutating func toggleCuisinePreference(_ cuisine: String) {
        if cuisinePreferences.contains(cuisine) {
            cuisinePreferences.remove(cuisine)
        } else {
            cuisinePreferences.insert(cuisine)
        }
    }
}
