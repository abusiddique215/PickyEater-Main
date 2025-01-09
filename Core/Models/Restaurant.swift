import Foundation

enum PriceRange: String, Codable {
    case oneDollar = "$"
    case twoDollars = "$$"
    case threeDollars = "$$$"
    case fourDollars = "$$$$"
    case other = "Other"
}

struct AppRestaurant: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let price: PriceRange
    let categories: [Category]
    // Add other necessary properties, ensuring all are Codable
    
    // Implement Equatable
    static func == (lhs: AppRestaurant, rhs: AppRestaurant) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Codable conformance is automatic unless custom decoding is needed
} 