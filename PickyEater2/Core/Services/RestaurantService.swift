import CoreLocation
import Foundation

actor RestaurantService {
    private let yelpAPIService: YelpAPIService
    private let locationManager: LocationManager

    init(yelpAPIService: YelpAPIService = YelpAPIService(), locationManager: LocationManager = LocationManager()) {
        self.yelpAPIService = yelpAPIService
        self.locationManager = locationManager
    }

    func fetchFeaturedRestaurants() async throws -> [Restaurant] {
        guard let location = await locationManager.currentLocation else {
            throw ServiceError.locationNotAvailable
        }

        let yelpRestaurants = try await yelpAPIService.searchRestaurants(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            term: "featured",
            limit: 10
        )

        return yelpRestaurants.map { yelpRestaurant in
            Restaurant(
                id: yelpRestaurant.id,
                name: yelpRestaurant.name,
                cuisineType: yelpRestaurant.categories.first?.title ?? "Restaurant",
                rating: yelpRestaurant.rating,
                priceLevel: yelpRestaurant.price ?? "$",
                imageURL: URL(string: yelpRestaurant.imageUrl),
                phoneNumber: yelpRestaurant.phone,
                address: yelpRestaurant.location.address1,
                city: yelpRestaurant.location.city,
                state: yelpRestaurant.location.state,
                zipCode: yelpRestaurant.location.zipCode,
                latitude: yelpRestaurant.coordinates.latitude,
                longitude: yelpRestaurant.coordinates.longitude,
                distance: yelpRestaurant.distance,
                reviewCount: yelpRestaurant.reviewCount
            )
        }
    }

    func fetchNearbyRestaurants() async throws -> [Restaurant] {
        guard let location = await locationManager.currentLocation else {
            throw ServiceError.locationNotAvailable
        }

        let yelpRestaurants = try await yelpAPIService.searchRestaurants(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            limit: 20
        )

        return yelpRestaurants.map { yelpRestaurant in
            Restaurant(
                id: yelpRestaurant.id,
                name: yelpRestaurant.name,
                cuisineType: yelpRestaurant.categories.first?.title ?? "Restaurant",
                rating: yelpRestaurant.rating,
                priceLevel: yelpRestaurant.price ?? "$",
                imageURL: URL(string: yelpRestaurant.imageUrl),
                phoneNumber: yelpRestaurant.phone,
                address: yelpRestaurant.location.address1,
                city: yelpRestaurant.location.city,
                state: yelpRestaurant.location.state,
                zipCode: yelpRestaurant.location.zipCode,
                latitude: yelpRestaurant.coordinates.latitude,
                longitude: yelpRestaurant.coordinates.longitude,
                distance: yelpRestaurant.distance,
                reviewCount: yelpRestaurant.reviewCount
            )
        }
    }

    func fetchRestaurantDetails(id: String) async throws -> Restaurant {
        let yelpRestaurant = try await yelpAPIService.fetchBusinessDetails(id: id)

        return Restaurant(
            id: yelpRestaurant.id,
            name: yelpRestaurant.name,
            cuisineType: yelpRestaurant.categories.first?.title ?? "Restaurant",
            rating: yelpRestaurant.rating,
            priceLevel: yelpRestaurant.price ?? "$",
            imageURL: URL(string: yelpRestaurant.imageUrl),
            phoneNumber: yelpRestaurant.phone,
            address: yelpRestaurant.location.address1,
            city: yelpRestaurant.location.city,
            state: yelpRestaurant.location.state,
            zipCode: yelpRestaurant.location.zipCode,
            latitude: yelpRestaurant.coordinates.latitude,
            longitude: yelpRestaurant.coordinates.longitude,
            distance: yelpRestaurant.distance,
            reviewCount: yelpRestaurant.reviewCount,
            hours: yelpRestaurant.hours?.first?.open.map { hour in
                BusinessHours(
                    day: hour.day,
                    open: hour.start,
                    close: hour.end,
                    isOvernight: hour.isOvernight
                )
            }
        )
    }
}

// MARK: - Service Error

enum ServiceError: LocalizedError {
    case locationNotAvailable

    var errorDescription: String? {
        switch self {
        case .locationNotAvailable:
            return "Location services are not available. Please enable location services to find restaurants near you."
        }
    }
}
