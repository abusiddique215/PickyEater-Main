import Foundation

// Define Category within your module to avoid ambiguity
struct Category: Codable, Equatable {
    let id: String
    let title: String
}

// Rename Restaurant to AppRestaurant to avoid ambiguity
struct AppRestaurant: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let categories: [Category]
    let price: PriceRange
    // other properties...

    // Custom Equatable conformance
    static func == (lhs: AppRestaurant, rhs: AppRestaurant) -> Bool {
        return lhs.id == rhs.id
    }
}

// Update any extensions or additional implementations accordingly 