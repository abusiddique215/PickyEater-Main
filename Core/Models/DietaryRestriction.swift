import Foundation

enum DietaryRestriction: String, CaseIterable, Codable, Identifiable {
    case vegetarian = "Vegetarian"
    case vegan = "Vegan"
    case glutenFree = "Gluten-Free"
    case dairyFree = "Dairy-Free"
    case nutFree = "Nut-Free"
    case halal = "Halal"
    case kosher = "Kosher"

    var id: String { rawValue }

    var description: String { rawValue }
}
