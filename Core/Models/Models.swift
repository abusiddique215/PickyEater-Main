import Foundation

// Retain only the Category struct
struct Category: Codable, Equatable {
    let alias: String
    let title: String
}

// Ensure no 'AppRestaurant' or 'Restaurant' structs are defined here

struct RestaurantSearchResponse: Codable {
    let businesses: [AppRestaurant]
    // Other properties...
}

// Remove any Equatable conformance for Restaurant if present
// static func == (lhs: Restaurant, rhs: Restaurant) -> Bool {
//     lhs.id == rhs.id
// }
