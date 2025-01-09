import Foundation

struct OpeningHours: Codable {
    let day: Int
    let start: String
    let end: String
    let isOvernight: Bool
}

extension AppRestaurant {
    struct OpeningHoursDetail: Codable {
        let open: [OpeningHours]
        let hoursType: String
        let isOpenNow: Bool

        enum CodingKeys: String, CodingKey {
            case open
            case hoursType = "hours_type"
            case isOpenNow = "is_open_now"
        }
    }

    // Update toAppRestaurant to include opening hours
    func toAppRestaurant(from data: [String: Any]) -> AppRestaurant {
        // Parsing logic...
    }
}

class YelpAPIService {
    // Existing methods...

    func fetchNearbyRestaurants() async throws -> [AppRestaurant] {
        // Example fetch logic...

        // Example of handling price range
        let price = data["price"] as? String ?? "Other"
        let priceRange = parsePriceRange(from: price)

        // Replace `.medium` with `.other`
        let priceLevel = PriceRange(rawValue: price) ?? .other

        // Use priceLevel accordingly
        // e.g., assign to `price` property of AppRestaurant
    }

    func parsePriceRange(from price: String) -> PriceRange {
        switch price {
        case "$":
            .oneDollar
        case "$$":
            .twoDollars
        case "$$$":
            .threeDollars
        case "$$$$":
            .fourDollars
        default:
            .other
        }
    }

    // Other methods...
}
