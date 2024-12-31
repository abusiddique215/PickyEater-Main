import Foundation
import SwiftData

@Model
final class UserPreferences {
    var id: String
    var maxDistance: Double
    var priceRange: String
    private var dietaryRestrictionsData: Data
    private var cuisinePreferencesData: Data
    
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
    
    init() {
        self.id = UUID().uuidString
        self.maxDistance = 5.0
        self.priceRange = "$$"
        self.dietaryRestrictionsData = Data()
        self.cuisinePreferencesData = Data()
    }
} 