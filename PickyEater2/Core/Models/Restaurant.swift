import Foundation

enum PriceRange: Int, Codable {
    case $, $$, $$$, $$$$, Other

    init(from value: String) {
        switch value {
        case "$":
            self = .$
        case "$$":
            self = $$
        case "$$$":
            self = $$$
        case "$$$$":
            self = $$$$
        default:
            self = .Other
        }
    }

    var rawValueString: String {
        switch self {
        case .$:
            "$"
        case $$:
            "$$"
        case $$$:
            "$$$"
        case $$$$:
            "$$$$"
        case .Other:
            "Other"
        }
    }
}

struct Category: Codable, Hashable {
    let alias: String
    let title: String
}

struct Restaurant: Codable, Identifiable {
    let id: String
    let name: String
    let distance: Double?
    let price: String?
    let categories: [Category]
    let imageUrl: String

    var priceRange: PriceRange {
        if let price {
            return PriceRange(from: price)
        }
        return .Other
    }
}
