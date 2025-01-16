import Foundation
import SwiftData

@MainActor
public final class PreferencesManager: ObservableObject {
    @Published public private(set) var preferences: UserPreferences
    private let modelContext: ModelContext
    
    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.preferences = UserPreferences()
        loadPreferences()
    }
    
    private func loadPreferences() {
        let descriptor = FetchDescriptor<UserPreferences>()
        if let existingPreferences = try? modelContext.fetch(descriptor).first {
            preferences = existingPreferences
        } else {
            preferences = UserPreferences()
            modelContext.insert(preferences)
            try? modelContext.save()
        }
    }
    
    public func updatePreferences(_ newPreferences: UserPreferences) {
        preferences = newPreferences
        try? modelContext.save()
    }
    
    public func updateDietaryRestrictions(_ restrictions: Set<DietaryRestriction>) {
        preferences.dietaryRestrictions = restrictions
        try? modelContext.save()
    }
    
    public func updateFavoriteCuisines(_ cuisines: Set<String>) {
        preferences.favoriteCuisines = cuisines
        try? modelContext.save()
    }
    
    public func updateCravings(_ cravings: Set<String>) {
        preferences.cravings = cravings
        try? modelContext.save()
    }
    
    public func updateLocation(_ location: UserPreferences.Location?) {
        preferences.location = location
        try? modelContext.save()
    }
    
    public func updateSubscriptionStatus(_ isSubscribed: Bool) {
        preferences.isSubscribed = isSubscribed
        try? modelContext.save()
    }
    
    public func updateSortOption(_ sortBy: UserPreferences.SortOption) {
        preferences.sortBy = sortBy
        try? modelContext.save()
    }
    
    public func updateMaxDistance(_ distance: Double) {
        preferences.maxDistance = distance
        try? modelContext.save()
    }
    
    public func updatePriceRange(_ priceRange: Set<String>) {
        preferences.priceRange = priceRange
        try? modelContext.save()
    }
    
    public func updateMinimumRating(_ rating: Double) {
        preferences.minimumRating = rating
        try? modelContext.save()
    }
    
    public func updateMaximumDistance(_ distance: Double) {
        preferences.maximumDistance = distance
        try? modelContext.save()
    }
    
    public func updateCuisinePreferences(_ preferences: [String: Double]) {
        self.preferences.cuisinePreferences = preferences
        try? modelContext.save()
    }
} 