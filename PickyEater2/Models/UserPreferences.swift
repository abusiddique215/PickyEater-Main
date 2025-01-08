import SwiftData
import SwiftUI

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
    var priceRange: Int
    var dietaryRestrictionsData: Data
    var cuisinePreferencesData: Data
    var theme: AppTheme

    var dietaryRestrictions: [String] {
        get { decodeArray(from: dietaryRestrictionsData) }
        set { dietaryRestrictionsData = encodeArray(newValue) }
    }

    var cuisinePreferences: [String] {
        get { decodeArray(from: cuisinePreferencesData) }
        set { cuisinePreferencesData = encodeArray(newValue) }
    }

    init(
        maxDistance: Int = 5,
        priceRange: Int = 2,
        dietaryRestrictions: [String] = [],
        cuisinePreferences: [String] = [],
        theme: AppTheme = .system
    ) {
        self.maxDistance = maxDistance
        self.priceRange = priceRange
        self.theme = theme
        dietaryRestrictionsData = Data()
        cuisinePreferencesData = Data()
        self.dietaryRestrictions = dietaryRestrictions
        self.cuisinePreferences = cuisinePreferences
    }

    private func encodeArray(_ array: [String]) -> Data {
        (try? JSONEncoder().encode(array)) ?? Data()
    }

    private func decodeArray(from data: Data) -> [String] {
        (try? JSONDecoder().decode([String].self, from: data)) ?? []
    }
}
