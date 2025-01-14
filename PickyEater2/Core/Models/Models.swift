import Foundation

// Common enums and protocols used across models
enum DietaryRestriction: String, Codable {
    case vegetarian
    case vegan
    case glutenFree
    case dairyFree
    case nutFree
    case halal
    case kosher
}

enum PriceRange: String, Codable {
    case cheap = "$"
    case moderate = "$$"
    case expensive = "$$$"
    case veryExpensive = "$$$$"
}

enum CuisineType: String, Codable, CaseIterable {
    case american
    case chinese
    case italian
    case japanese
    case mexican
    case indian
    case thai
    case mediterranean
    case french
    case korean
    case vietnamese
    case greek
    case other
}

// Protocol for model identifiable objects
protocol ModelIdentifiable {
    var id: String { get }
} 