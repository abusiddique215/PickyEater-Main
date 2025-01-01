import SwiftUI
import SwiftData

enum AppTheme: String, Codable {
    case light, dark, system
    
    var colorScheme: ColorScheme? {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
}

@Model
final class UserPreferences {
    var maxDistance: Int
    var priceRange: [Int]
    var dietaryRestrictions: [String]
    var cuisinePreferences: [String]
    var theme: AppTheme
    
    init(
        maxDistance: Int = 5,
        priceRange: [Int] = [1, 2, 3],
        dietaryRestrictions: [String] = [],
        cuisinePreferences: [String] = [],
        theme: AppTheme = .system
    ) {
        self.maxDistance = maxDistance
        self.priceRange = priceRange
        self.dietaryRestrictions = dietaryRestrictions
        self.cuisinePreferences = cuisinePreferences
        self.theme = theme
    }
} 