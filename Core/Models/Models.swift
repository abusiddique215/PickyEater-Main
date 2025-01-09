import Foundation

// Retain only the Category struct
struct Category: Codable, Equatable {
    let id: String
    let title: String
}

// Remove all references to Restaurant or AppRestaurant
// Ensure no 'AppRestaurant' or 'Restaurant' structs are defined here 