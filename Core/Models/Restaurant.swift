import Foundation

enum PriceRange: String, Codable {
    case oneDollar = "$"
    case twoDollars = "$$"
    case threeDollars = "$$$"
    case fourDollars = "$$$$"
    case other = "Other"

    init(from value: String) {
        switch value {
        case "$":
            self = .oneDollar
        case "$$":
            self = .twoDollars
        case "$$$":
            self = .threeDollars
        case "$$$$":
            self = .fourDollars
        default:
            self = .other
        }
    }

    var rawValueString: String {
        rawValue
    }
}

struct AppRestaurant: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let distance: Double?
    let priceRange: PriceRange
    let categories: [Category]
    let imageUrl: String

    // Implement Equatable
    static func == (lhs: AppRestaurant, rhs: AppRestaurant) -> Bool {
        lhs.id == rhs.id
    }

    // Codable conformance is automatic unless custom decoding is needed
}
