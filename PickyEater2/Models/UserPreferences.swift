import Foundation

enum DietaryRestriction: String, CaseIterable, Codable {
    case vegetarian
    case vegan
    case glutenFree = "gluten-free"
    case dairyFree = "dairy-free"
    
    var description: String {
        switch self {
        case .vegetarian: return "Vegetarian"
        case .vegan: return "Vegan"
        case .glutenFree: return "Gluten-Free"
        case .dairyFree: return "Dairy-Free"
        }
    }
}

enum PriceRange: Int, CaseIterable, Codable {
    case low = 1      // $
    case medium = 2   // $$
    case high = 3     // $$$
    case veryHigh = 4 // $$$$
    
    var description: String {
        String(repeating: "$", count: rawValue)
    }
}

struct UserPreferences: Codable {
    var dietaryRestrictions: Set<DietaryRestriction>
    var cuisinePreferences: Set<String>
    var priceRange: PriceRange?
    var minimumRating: Double?
    var maximumDistance: Double? // in meters
    var sortBy: SortOption
    
    enum SortOption: String, CaseIterable, Codable {
        case bestMatch = "best_match"
        case rating = "rating"
        case reviewCount = "review_count"
        case distance = "distance"
    }
    
    init(
        dietaryRestrictions: Set<DietaryRestriction> = [],
        cuisinePreferences: Set<String> = [],
        priceRange: PriceRange? = nil,
        minimumRating: Double? = nil,
        maximumDistance: Double? = nil,
        sortBy: SortOption = .bestMatch
    ) {
        self.dietaryRestrictions = dietaryRestrictions
        self.cuisinePreferences = cuisinePreferences
        self.priceRange = priceRange
        self.minimumRating = minimumRating
        self.maximumDistance = maximumDistance
        self.sortBy = sortBy
    }
}

// MARK: - UserDefaults Extension
extension UserDefaults {
    private static let preferencesKey = "user_preferences"
    
    var userPreferences: UserPreferences {
        get {
            guard let data = data(forKey: UserDefaults.preferencesKey),
                  let preferences = try? JSONDecoder().decode(UserPreferences.self, from: data) else {
                return UserPreferences()
            }
            return preferences
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else { return }
            set(data, forKey: UserDefaults.preferencesKey)
        }
    }
}

// MARK: - Notification Support
extension UserPreferences {
    static let preferencesChangedNotification = Notification.Name("UserPreferencesChanged")
    
    func save() {
        UserDefaults.standard.userPreferences = self
        NotificationCenter.default.post(name: Self.preferencesChangedNotification, object: nil)
    }
}

// MARK: - Preference Management
extension UserPreferences {
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
    
    mutating func clearAllPreferences() {
        dietaryRestrictions.removeAll()
        cuisinePreferences.removeAll()
        priceRange = nil
        minimumRating = nil
        maximumDistance = nil
        sortBy = .bestMatch
    }
    
    func matches(_ restaurant: Restaurant) -> Bool {
        // Price range check
        if let preferredPrice = priceRange,
           restaurant.priceRange.rawValue > preferredPrice.rawValue {
            return false
        }
        
        // Rating check
        if let minRating = minimumRating,
           restaurant.rating < minRating {
            return false
        }
        
        // Distance check
        if let maxDistance = maximumDistance,
           restaurant.distance > maxDistance {
            return false
        }
        
        // Dietary restrictions check
        if !dietaryRestrictions.isEmpty {
            let restaurantCategories = Set(restaurant.categories.map { $0.lowercased() })
            let requiredCategories = Set(dietaryRestrictions.map { $0.rawValue })
            if !requiredCategories.isSubset(of: restaurantCategories) {
                return false
            }
        }
        
        // Cuisine preferences check
        if !cuisinePreferences.isEmpty {
            let restaurantCuisines = Set(restaurant.categories.map { $0.lowercased() })
            let preferredCuisines = Set(cuisinePreferences.map { $0.lowercased() })
            if restaurantCuisines.isDisjoint(with: preferredCuisines) {
                return false
            }
        }
        
        return true
    }
}
