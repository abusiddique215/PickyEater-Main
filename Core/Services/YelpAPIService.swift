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
    
    // Update toRestaurant to include opening hours
    func toAppRestaurant(from data: [String: Any]) -> AppRestaurant {
        // Parsing logic...
    }
} 