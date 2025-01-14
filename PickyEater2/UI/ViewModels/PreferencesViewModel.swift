import Foundation
import PickyEater2Core
import SwiftUI

@MainActor
class PreferencesViewModel: ObservableObject {
    @Published private(set) var preferences: UserPreferences {
        didSet {
            save()
        }
    }

    @Published var availableCuisines: [String] = [
        "American", "Chinese", "Italian", "Japanese", "Mexican",
        "Thai", "Indian", "Mediterranean", "Korean", "Vietnamese",
        "French", "Greek", "Spanish", "Middle Eastern", "Brazilian",
    ]

    init() {
        preferences = UserPreferences()
        loadPreferences()
    }

    // MARK: - Dietary Restrictions

    var dietaryRestrictions: Set<DietaryRestriction> {
        preferences.dietaryRestrictions
    }

    func toggleDietaryRestriction(_ restriction: DietaryRestriction) {
        var updatedPreferences = preferences
        if updatedPreferences.dietaryRestrictions.contains(restriction) {
            updatedPreferences.dietaryRestrictions.remove(restriction)
        } else {
            updatedPreferences.dietaryRestrictions.insert(restriction)
        }
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
            guard rating >= 0, rating <= 5 else {
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
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.number(from: string)?.doubleValue
    }

    // MARK: - Private Methods

    private func loadPreferences() {
        if let data = UserDefaults.standard.data(forKey: "UserPreferences"),
           let decoded = try? JSONDecoder().decode(UserPreferences.self, from: data)
        {
            preferences = decoded
        }
    }

    private func save() {
        if let encoded = try? JSONEncoder().encode(preferences) {
            UserDefaults.standard.set(encoded, forKey: "UserPreferences")
        }
    }
}
