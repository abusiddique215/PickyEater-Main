import Foundation

public enum DietaryRestriction: String, Codable, CaseIterable {
    case dairyFree = "Dairy-Free"
    case nutFree = "Nut-Free"
    case halal = "Halal"
    case kosher = "Kosher"

    public var id: String { rawValue }
    public var description: String { rawValue }
}
