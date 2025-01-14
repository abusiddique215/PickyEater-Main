import Combine
import PickyEater2Core
import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    @Published private(set) var restaurants: [AppRestaurant] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    @Published var selectedRestaurant: AppRestaurant?

    private let yelpService: YelpAPIService
    private let locationManager: LocationManager
    private let filterService: RestaurantFilterService
    private var cancellables = Set<AnyCancellable>()

    init(
        yelpService: YelpAPIService,
        locationManager: LocationManager,
        filterService: RestaurantFilterService
    ) {
        self.yelpService = yelpService
        self.locationManager = locationManager
        self.filterService = filterService

        setupLocationUpdates()
        setupPreferencesUpdates()
    }

    private func setupLocationUpdates() {
        locationManager.$location
            .sink { [weak self] location in
                guard let location = location else { return }
                Task {
                    await self?.loadRestaurants(at: location)
                }
            }
            .store(in: &cancellables)
    }

    private func setupPreferencesUpdates() {
        NotificationCenter.default.publisher(for: UserPreferences.preferencesChangedNotification)
            .sink { [weak self] _ in
                Task {
                    if let location = self?.locationManager.location {
                        await self?.loadRestaurants(at: location)
                    }
                }
            }
            .store(in: &cancellables)
    }

    private func loadRestaurants(at location: CLLocation) async {
        isLoading = true
        defer { isLoading = false }

        do {
            let preferences = PreferencesManager.shared.userPreferences
            let fetchedRestaurants = try await yelpService.searchRestaurants(
                location: location,
                preferences: preferences,
                radius: Int(preferences.maxDistance * 1000)
            )

            let filteredRestaurants = filterService.filterRestaurants(fetchedRestaurants, preferences: preferences)
            restaurants = filterService.sortRestaurantsByPreference(filteredRestaurants, preferences: preferences)
        } catch {
            self.error = error
            restaurants = []
        }
    }

    func requestLocationPermission() {
        locationManager.requestAuthorization()
    }
}

// MARK: - Errors

extension HomeViewModel {
    enum LocationError: LocalizedError {
        case locationNotAvailable

        var errorDescription: String? {
            switch self {
            case .locationNotAvailable:
                "Unable to get your location. Please enable location services to see nearby restaurants."
            }
        }
    }
}
