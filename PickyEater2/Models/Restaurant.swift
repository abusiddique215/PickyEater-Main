import Foundation

struct Restaurant: Identifiable, Codable {
    let id: String
    let name: String
    let cuisineType: String
    let rating: Double
    let priceLevel: String
    let imageURL: URL?
    var isFavorite: Bool = false
    
    // Optional properties
    var phoneNumber: String?
    var address: String?
    var city: String?
    var state: String?
    var zipCode: String?
    var latitude: Double?
    var longitude: Double?
    var distance: Double?
    var reviewCount: Int?
    var hours: [BusinessHours]?
    
    // Computed properties
    var formattedAddress: String? {
        guard let address = address,
              let city = city,
              let state = state,
              let zipCode = zipCode else { return nil }
        return "\(address), \(city), \(state) \(zipCode)"
    }
    
    var coordinates: (latitude: Double, longitude: Double)? {
        guard let latitude = latitude,
              let longitude = longitude else { return nil }
        return (latitude, longitude)
    }
}

struct BusinessHours: Codable {
    let day: Int // 0 = Sunday, 1 = Monday, etc.
    let open: String
    let close: String
    let isOvernight: Bool
}

// MARK: - Sample Data

extension Restaurant {
    static let sample = Restaurant(
        id: "1",
        name: "Sample Restaurant",
        cuisineType: "Italian",
        rating: 4.5,
        priceLevel: "$$$",
        imageURL: nil,
        phoneNumber: "(555) 123-4567",
        address: "123 Main St",
        city: "San Francisco",
        state: "CA",
        zipCode: "94105",
        latitude: 37.7749,
        longitude: -122.4194,
        distance: 1200,
        reviewCount: 256,
        hours: [
            BusinessHours(day: 1, open: "11:00", close: "22:00", isOvernight: false),
            BusinessHours(day: 2, open: "11:00", close: "22:00", isOvernight: false),
            BusinessHours(day: 3, open: "11:00", close: "22:00", isOvernight: false),
            BusinessHours(day: 4, open: "11:00", close: "23:00", isOvernight: false),
            BusinessHours(day: 5, open: "11:00", close: "23:00", isOvernight: false),
            BusinessHours(day: 6, open: "10:00", close: "23:00", isOvernight: false),
            BusinessHours(day: 0, open: "10:00", close: "22:00", isOvernight: false)
        ]
    )
    
    static let samples = [
        Restaurant(
            id: "1",
            name: "Italian Delight",
            cuisineType: "Italian",
            rating: 4.5,
            priceLevel: "$$$",
            imageURL: nil
        ),
        Restaurant(
            id: "2",
            name: "Sushi Express",
            cuisineType: "Japanese",
            rating: 4.8,
            priceLevel: "$$",
            imageURL: nil
        ),
        Restaurant(
            id: "3",
            name: "Taco Paradise",
            cuisineType: "Mexican",
            rating: 4.2,
            priceLevel: "$",
            imageURL: nil
        )
    ]
} 