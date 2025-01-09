import Foundation

enum DietaryRestriction: String, CaseIterable, Codable, Identifiable {
    case vegetarian = "Vegetarian"
    case vegan = "Vegan"
    case glutenFree = "Gluten-Free"
    case dairyFree = "Dairy-Free"
    case nutFree = "Nut-Free"
    // add more if needed

    var id: String { rawValue }
}
