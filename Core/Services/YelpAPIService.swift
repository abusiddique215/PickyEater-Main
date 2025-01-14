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
}

class YelpAPIService {
    private let apiKey: String
    
    init(apiKey: String = "") {
        self.apiKey = apiKey
    }

    func fetchNearbyRestaurants() async throws -> [AppRestaurant] {
        // This is a placeholder implementation
        // In a real app, you would make an actual API call to Yelp
        return []
    }

    private func parsePriceRange(from price: String) -> PriceRange {
        PriceRange(from: price)
    }
}
