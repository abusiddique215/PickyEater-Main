import Foundation
import CoreLocation

public actor RestaurantService {
    private let yelpAPIService: YelpAPIService
    private let locationManager: LocationManager
    
    public init(yelpAPIService: YelpAPIService, locationManager: LocationManager) {
        self.yelpAPIService = yelpAPIService
        self.locationManager = locationManager
    }
    
    public func fetchFeaturedRestaurants() async throws -> [Restaurant] {
        guard let location = await locationManager.currentLocation else {
            throw ServiceError.locationNotAvailable
        }
        
        return try await yelpAPIService.searchRestaurants(
            term: "featured",
            location: location,
            limit: 10
        )
    }
    
    public func fetchNearbyRestaurants() async throws -> [Restaurant] {
        guard let location = await locationManager.currentLocation else {
            throw ServiceError.locationNotAvailable
        }
        
        return try await yelpAPIService.searchRestaurants(
            term: "restaurants",
            location: location,
            limit: 20
        )
    }
    
    public func fetchRestaurantDetails(id: String) async throws -> Restaurant {
        return try await yelpAPIService.fetchBusinessDetails(id: id)
    }
}

public enum ServiceError: LocalizedError {
    case locationNotAvailable
    
    public var errorDescription: String? {
        switch self {
        case .locationNotAvailable:
            return "Location services are not available. Please enable location services to continue."
        }
    }
}
