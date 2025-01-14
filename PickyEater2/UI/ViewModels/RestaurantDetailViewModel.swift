import Combine
import MapKit
import PickyEater2Core
import SwiftUI

@MainActor
class RestaurantDetailViewModel: ObservableObject {
    @Published var restaurant: AppRestaurant
    @Published var isLoading = false
    @Published var error: Error?
    @Published var isFavorite = false
    @Published var reviews: [Review] = []
    @Published var region: MKCoordinateRegion

    private let yelpService: YelpAPIService
    private var cancellables = Set<AnyCancellable>()

    init(restaurant: AppRestaurant, yelpService: YelpAPIService) {
        self.restaurant = restaurant
        self.yelpService = yelpService
        region = MKCoordinateRegion(
            center: restaurant.coordinates,
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
    }

    func loadReviews() async {
        isLoading = true
        defer { isLoading = false }

        do {
            reviews = try await yelpService.fetchReviews(for: restaurant.id)
        } catch {
            self.error = error
        }
    }

    func toggleFavorite() {
        isFavorite.toggle()
        // Implement favorite persistence logic here
    }
}
