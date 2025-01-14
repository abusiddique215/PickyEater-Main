import Foundation
import CoreLocation

struct UserPreferences: Codable {
    var dietaryRestrictions: Set<DietaryRestriction>
    var favoriteCuisines: Set<CuisineType>
    var maxPriceRange: PriceRange
    var searchRadius: Double // in kilometers
    var location: CLLocationCoordinate2D?
    var savedRestaurants: Set<String> // restaurant IDs
    var excludedRestaurants: Set<String> // restaurant IDs to hide
    var minRating: Double
    
    enum CodingKeys: String, CodingKey {
        case dietaryRestrictions
        case favoriteCuisines
        case maxPriceRange
        case searchRadius
        case latitude
        case longitude
        case savedRestaurants
        case excludedRestaurants
        case minRating
    }
    
    init(dietaryRestrictions: Set<DietaryRestriction> = [],
         favoriteCuisines: Set<CuisineType> = [],
         maxPriceRange: PriceRange = .moderate,
         searchRadius: Double = 5.0,
         location: CLLocationCoordinate2D? = nil,
         savedRestaurants: Set<String> = [],
         excludedRestaurants: Set<String> = [],
         minRating: Double = 3.5) {
        self.dietaryRestrictions = dietaryRestrictions
        self.favoriteCuisines = favoriteCuisines
        self.maxPriceRange = maxPriceRange
        self.searchRadius = searchRadius
        self.location = location
        self.savedRestaurants = savedRestaurants
        self.excludedRestaurants = excludedRestaurants
        self.minRating = minRating
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        dietaryRestrictions = try container.decode(Set<DietaryRestriction>.self, forKey: .dietaryRestrictions)
        favoriteCuisines = try container.decode(Set<CuisineType>.self, forKey: .favoriteCuisines)
        maxPriceRange = try container.decode(PriceRange.self, forKey: .maxPriceRange)
        searchRadius = try container.decode(Double.self, forKey: .searchRadius)
        savedRestaurants = try container.decode(Set<String>.self, forKey: .savedRestaurants)
        excludedRestaurants = try container.decode(Set<String>.self, forKey: .excludedRestaurants)
        minRating = try container.decode(Double.self, forKey: .minRating)
        
        if let latitude = try container.decodeIfPresent(Double.self, forKey: .latitude),
           let longitude = try container.decodeIfPresent(Double.self, forKey: .longitude) {
            location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        } else {
            location = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(dietaryRestrictions, forKey: .dietaryRestrictions)
        try container.encode(favoriteCuisines, forKey: .favoriteCuisines)
        try container.encode(maxPriceRange, forKey: .maxPriceRange)
        try container.encode(searchRadius, forKey: .searchRadius)
        try container.encode(savedRestaurants, forKey: .savedRestaurants)
        try container.encode(excludedRestaurants, forKey: .excludedRestaurants)
        try container.encode(minRating, forKey: .minRating)
        
        if let location = location {
            try container.encode(location.latitude, forKey: .latitude)
            try container.encode(location.longitude, forKey: .longitude)
        }
    }
} 