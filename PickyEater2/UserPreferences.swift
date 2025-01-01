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
    var priceRange: Int
    @Attribute(transform: StringArrayTransformer())
    var dietaryRestrictions: [String]
    @Attribute(transform: StringArrayTransformer())
    var cuisinePreferences: [String]
    var theme: AppTheme
    
    init(
        maxDistance: Int = 5,
        priceRange: Int = 2,
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

// MARK: - Value Transformers
class StringArrayTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass {
        NSArray.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        true
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let array = value as? [String] else { return nil }
        return array as NSArray
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let array = value as? NSArray else { return nil }
        return array as? [String]
    }
} 