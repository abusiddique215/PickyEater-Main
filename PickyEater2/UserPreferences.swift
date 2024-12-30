import Foundation
import SwiftData

@Model
final class UserPreferences {
    var maxDistance: Double = 5.0
    var priceRange: String = "$$"
    private var dietaryRestrictionsData: Data = Data()
    private var cuisinePreferencesData: Data = Data()
    
    var dietaryRestrictions: [String] {
        get {
            (try? JSONDecoder().decode([String].self, from: dietaryRestrictionsData)) ?? []
        }
        set {
            dietaryRestrictionsData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }
    
    var cuisinePreferences: [String] {
        get {
            (try? JSONDecoder().decode([String].self, from: cuisinePreferencesData)) ?? []
        }
        set {
            cuisinePreferencesData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }
    
    init() {}
    
    init(maxDistance: Double, priceRange: String, dietaryRestrictions: [String], cuisinePreferences: [String]) {
        self.maxDistance = maxDistance
        self.priceRange = priceRange
        self.dietaryRestrictions = dietaryRestrictions
        self.cuisinePreferences = cuisinePreferences
    }
} 