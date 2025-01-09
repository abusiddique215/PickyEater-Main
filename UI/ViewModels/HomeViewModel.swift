import Combine
import Foundation

@MainActor
class HomeViewModel: ObservableObject {
    @Published private(set) var restaurants: [AppRestaurant] = []
    @Published var selectedRestaurant: AppRestaurant?

    private var cancellables = Set<AnyCancellable>()
    private let yelpService: YelpAPIService
    private let locationManager: LocationManager

    init(yelpService: YelpAPIService = YelpAPIService(), locationManager: LocationManager = LocationManager()) {
        self.yelpService = yelpService
        self.locationManager = locationManager
        fetchRestaurants()
    }

    func fetchRestaurants() {
        Task {
            do {
                let fetchedRestaurants = try await yelpService.fetchNearbyRestaurants()
                DispatchQueue.main.async {
                    self.restaurants = fetchedRestaurants
                }
            } catch {
                // Handle error appropriately
            }
        }
    }

    // Other methods...
}
