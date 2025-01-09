import Foundation

class YelpAPIService {
    // Existing methods...
    
    func toRestaurant() -> AppRestaurant {
        // Assuming this method converts API data to AppRestaurant
    }
    
    // Example fix for PriceRange initialization
    func parsePriceRange(from price: String) -> PriceRange {
        switch price {
        case "$":
            return .oneDollar
        case "$$":
            return .twoDollars
        case "$$$":
            return .threeDollars
        case "$$$$":
            return .fourDollars
        default:
            return .other
        }
    }
    
    // Other methods...
} 