import Foundation
import CoreLocation

struct Restaurant: Model {
    let id: String
    let name: String
    let cuisineType: Cuisine
    let dietaryOptions: Set<DietaryRestriction>
    let rating: Double
    let priceLevel: String // "$", "$$", "$$$", "$$$$"
    let location: CLLocation
    let address: String
    let imageURL: URL?
    let distance: Double?
    let isOpen: Bool
    let phoneNumber: String?
    
    // Affiliate links
    let uberEatsURL: URL?
    let doorDashURL: URL?
    let grubHubURL: URL?
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Restaurant, rhs: Restaurant) -> Bool {
        lhs.id == rhs.id
    }
} 