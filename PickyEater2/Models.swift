import Foundation

// MARK: - Restaurant Models
struct Restaurant: Identifiable, Hashable {
    let id: String
    let name: String
    let location: Location
    let categories: [Category]
    let photos: [String]
    let rating: Double
    let reviewCount: Int
    let price: String?
    let displayPhone: String?
    
    static func == (lhs: Restaurant, rhs: Restaurant) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct Location: Hashable {
    let address1: String
    let city: String
    let state: String
    let country: String
    let latitude: Double
    let longitude: Double
    let zipCode: String?
}

struct Category: Hashable {
    let alias: String
    let title: String
} 