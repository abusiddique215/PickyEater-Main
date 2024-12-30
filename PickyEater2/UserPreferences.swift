import Foundation
import SwiftData

@Model
final class UserPreferences {
    var maxDistance: Double
    var priceRange: String
    @Attribute(.transformable) var dietaryRestrictions: [String]
    @Attribute(.transformable) var cuisinePreferences: [String]
    
    init(maxDistance: Double = 5.0, priceRange: String = "$$", dietaryRestrictions: [String] = [], cuisinePreferences: [String] = []) {
        self.maxDistance = maxDistance
        self.priceRange = priceRange
        self.dietaryRestrictions = dietaryRestrictions
        self.cuisinePreferences = cuisinePreferences
    }
} 