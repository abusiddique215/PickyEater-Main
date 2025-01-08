import Combine
import Foundation

@MainActor
class PreferencesViewModel: ObservableObject {
    @Published private(set) var preferences: UserPreferences {
        didSet {
            preferences.save()
        }
    }

    @Published var availableCuisines: [String] = [
        "American", "Chinese", "Italian", "Japanese", "Mexican",
        "Thai", "Indian", "Mediterranean", "Korean", "Vietnamese",
        "French", "Greek", "Spanish", "Middle Eastern", "Brazilian",
    ]

    init() {
        preferences = UserDefaults.standard.userPreferences
    }

    // MARK: - Dietary Restrictions

    var dietaryRestrictions: Set<DietaryRestriction> {
        preferences.dietaryRestrictions
    }

    func toggleDietaryRestriction(_ restriction: DietaryRestriction) {
        var updatedPreferences = preferences
        updatedPreferences.toggleDietaryRestriction(restriction)
        preferences = updatedPreferences
    }

    func isDietaryRestrictionEnabled(_ restriction: DietaryRestriction) -> Bool {
        preferences.dietaryRestrictions.contains(restriction)
    }

    // MARK: - Cuisine Preferences

    var cuisinePreferences: Set<String> {
        preferences.cuisinePreferences
    }

    func toggleCuisinePreference(_ cuisine: String) {
        var updatedPreferences = preferences
        updatedPreferences.toggleCuisinePreference(cuisine)
        preferences = updatedPreferences
    }

    func isCuisineSelected(_ cuisine: String) -> Bool {
        preferences.cuisinePreferences.contains(cuisine)
    }

    // MARK: - Price Range

    var priceRange: PriceRange? {
        get { preferences.priceRange }
        set {
            var updatedPreferences = preferences
            updatedPreferences.priceRange = newValue
            preferences = updatedPreferences
        }
    }

    // MARK: - Rating

    var minimumRating: Double? {
        get { preferences.minimumRating }
        set {
            var updatedPreferences = preferences
            updatedPreferences.minimumRating = newValue
            preferences = updatedPreferences
        }
    }

    // MARK: - Distance

    var maximumDistance: Double? {
        get { preferences.maximumDistance }
        set {
            var updatedPreferences = preferences
            updatedPreferences.maximumDistance = newValue
            preferences = updatedPreferences
        }
    }

    // MARK: - Sort Option

    var sortBy: UserPreferences.SortOption {
        get { preferences.sortBy }
        set {
            var updatedPreferences = preferences
            updatedPreferences.sortBy = newValue
            preferences = updatedPreferences
        }
    }

    // MARK: - Reset

    func resetAllPreferences() {
        preferences = UserPreferences()
    }

    // MARK: - Validation

    func validatePreferences() -> Bool {
        // Ensure at least one cuisine preference is selected
        guard !preferences.cuisinePreferences.isEmpty else {
            return false
        }

        // Validate rating range
        if let rating = preferences.minimumRating {
            guard rating >= 0 && rating <= 5 else {
                return false
            }
        }

        // Validate distance
        if let distance = preferences.maximumDistance {
            guard distance > 0 else {
                return false
            }
        }

        return true
    }

    // MARK: - Helper Methods

    func formattedDistance(_ distance: Double) -> String {
        let formatter = MeasurementFormatter()
        let measurement = Measurement(value: distance / 1000, unit: UnitLength.kilometers)
        return formatter.string(from: measurement)
    }

    func distanceFromString(_ string: String) -> Double? {
        let formatter = MeasurementFormatter()
        guard let measurement = formatter.number(from: string, unit: .kilometers) else {
            return nil
        }
        return measurement.value * 1000 // Convert to meters
    }
}
