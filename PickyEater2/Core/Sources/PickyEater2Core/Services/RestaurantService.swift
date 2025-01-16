import Foundation
import CoreLocation

public final class RestaurantService {
    private let yelpAPIService: YelpAPIService
    private let locationManager: LocationManager
    
    public init(yelpAPIService: YelpAPIService, locationManager: LocationManager) {
        self.yelpAPIService = yelpAPIService
        self.locationManager = locationManager
    }
    
    public func fetchFeaturedRestaurants() async throws -> [Restaurant] {
        guard let locationString = await locationManager.currentLocation else {
            throw ServiceError.locationNotAvailable
        }
        
        let components = locationString.split(separator: ",")
        guard components.count == 2,
              let latitude = Double(components[0]),
              let longitude = Double(components[1]) else {
            throw ServiceError.invalidLocation
        }
        
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        return try await yelpAPIService.searchRestaurants(
            location: location,
            term: "featured",
            limit: 10
        )
    }
    
    public func fetchNearbyRestaurants() async throws -> [Restaurant] {
        guard let locationString = await locationManager.currentLocation else {
            throw ServiceError.locationNotAvailable
        }
        
        let components = locationString.split(separator: ",")
        guard components.count == 2,
              let latitude = Double(components[0]),
              let longitude = Double(components[1]) else {
            throw ServiceError.invalidLocation
        }
        
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        return try await yelpAPIService.searchRestaurants(
            location: location,
            limit: 20
        )
    }
    
    public func fetchRestaurantDetails(id: String) async throws -> Restaurant {
        try await yelpAPIService.fetchBusinessDetails(id: id)
    }
}

extension RestaurantService {
    public enum ServiceError: LocalizedError {
        case locationNotAvailable
        case invalidLocation
        
        public var errorDescription: String? {
            switch self {
            case .locationNotAvailable:
                return "Location services are not available. Please enable location access in Settings."
            case .invalidLocation:
                return "Invalid location format received from location services."
            }
        }
    }
}
