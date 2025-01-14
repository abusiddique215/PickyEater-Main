import Foundation

// Common enums and protocols used across models
public enum DietaryRestriction: String, Codable {
    case vegetarian
    case vegan
    case glutenFree
    case dairyFree
    case nutFree
    case halal
    case kosher
}

public enum PriceRange: String, Codable {
    case cheap = "$"
    case moderate = "$$"
    case expensive = "$$$"
    case veryExpensive = "$$$$"
}

public enum CuisineType: String, Codable, CaseIterable {
    case american
    case chinese
    case italian
    case japanese
    case mexican
    case indian
    case thai
    case mediterranean
    case french
    case korean
    case vietnamese
    case greek
    case other
}

// Protocol for model identifiable objects
public protocol ModelIdentifiable {
    var id: String { get }
}

// API Response Models
public struct RestaurantSearchResponse: Codable {
    public let restaurants: [AppRestaurant]

    public init(restaurants: [AppRestaurant]) {
        self.restaurants = restaurants
    }
}

public struct AppRestaurant: Codable {
    public let id: String
    public let name: String
    public let rating: Double
    public let reviewCount: Int
    public let priceLevel: String?
    public let categories: [String]
    public let imageUrl: String?
    public let coordinates: Coordinates
    public let location: Location
    
    public init(id: String, name: String, rating: Double, reviewCount: Int, priceLevel: String?, categories: [String], imageUrl: String?, coordinates: Coordinates, location: Location) {
        self.id = id
        self.name = name
        self.rating = rating
        self.reviewCount = reviewCount
        self.priceLevel = priceLevel
        self.categories = categories
        self.imageUrl = imageUrl
        self.coordinates = coordinates
        self.location = location
    }
}

public struct Coordinates: Codable {
    public let latitude: Double
    public let longitude: Double
    
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

public struct Location: Codable {
    public let address1: String
    public let address2: String?
    public let address3: String?
    public let city: String
    public let state: String
    public let zipCode: String
    public let country: String
    
    public init(address1: String, address2: String?, address3: String?, city: String, state: String, zipCode: String, country: String) {
        self.address1 = address1
        self.address2 = address2
        self.address3 = address3
        self.city = city
        self.state = state
        self.zipCode = zipCode
        self.country = country
    }
}
