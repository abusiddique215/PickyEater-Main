import Combine
import CoreLocation
import Foundation

@MainActor
class HomeViewModel: ObservableObject {
    @Published private(set) var restaurants: [Restaurant] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    @Published var selectedRestaurant: Restaurant?

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
            .compactMap { $0 }
            .removeDuplicates()
            .sink { [weak self] _ in
                Task {
                    await self?.fetchRestaurants()
                }
            }
            .store(in: &cancellables)
    }

    private func setupPreferencesUpdates() {
        NotificationCenter.default.publisher(for: UserPreferences.preferencesChangedNotification)
            .sink { [weak self] _ in
                Task {
                    await self?.fetchRestaurants()
                }
            }
            .store(in: &cancellables)
    }

    func fetchRestaurants() async {
        guard let location = locationManager.location else {
            error = LocationError.locationNotAvailable
            return
        }

        isLoading = true
        error = nil

        do {
            let preferences = UserDefaults.standard.userPreferences
            let fetchedRestaurants = try await yelpService.searchRestaurants(
                location: location,
                categories: Array(preferences.cuisinePreferences),
                price: preferences.priceRange,
                radius: Int(preferences.maximumDistance ?? 5000)
            )

            // Filter and sort restaurants based on user preferences
            let filteredRestaurants = filterService.filterRestaurants(fetchedRestaurants, preferences: preferences)
            restaurants = filterService.sortRestaurantsByPreference(filteredRestaurants, preferences: preferences)
        } catch {
            self.error = error
            restaurants = []
        }

        isLoading = false
    }

    func refreshRestaurants() async {
        await fetchRestaurants()
    }

    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
}

// MARK: - Errors

extension HomeViewModel {
    enum LocationError: LocalizedError {
        case locationNotAvailable

        var errorDescription: String? {
            switch self {
            case .locationNotAvailable:
                return "Unable to get your location. Please enable location services to see nearby restaurants."
            }
        }
    }
}
