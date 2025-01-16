import Foundation

public enum DietaryRestriction: String, Codable, CaseIterable, Hashable {
    case vegetarian = "vegetarian"
    case vegan = "vegan"
    case glutenFree = "gluten_free"
    case dairyFree = "dairy_free"
    case nutFree = "nut_free"
    case halal = "halal"
    case kosher = "kosher"
    
    public var description: String {
        switch self {
        case .vegetarian: return "Vegetarian"
        case .vegan: return "Vegan"
        case .glutenFree: return "Gluten Free"
        case .dairyFree: return "Dairy Free"
        case .nutFree: return "Nut Free"
        case .halal: return "Halal"
        case .kosher: return "Kosher"
        }
    }
    
    public var searchTerms: [String] {
        switch self {
        case .vegetarian:
            return ["vegetarian", "veggie"]
        case .vegan:
            return ["vegan", "plant-based"]
        case .glutenFree:
            return ["gluten-free", "gluten free", "gf"]
        case .dairyFree:
            return ["dairy-free", "dairy free", "non-dairy"]
        case .nutFree:
            return ["nut-free", "nut free", "peanut-free"]
        case .halal:
            return ["halal"]
        case .kosher:
            return ["kosher", "kosher-certified"]
        }
    }
} 