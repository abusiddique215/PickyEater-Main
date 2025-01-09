import Foundation

enum DietaryRestriction: String, CaseIterable, Codable, Identifiable {
    case vegetarian = "Vegetarian"
    case vegan = "Vegan"
    case glutenFree = "Gluten-Free"
    case dairyFree = "Dairy-Free"
    case nutFree = "Nut-Free"
    // Add other restrictions as needed

    var id: String { rawValue }
}
