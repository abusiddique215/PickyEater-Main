import Foundation

@MainActor
class RestaurantDetailViewModel: ObservableObject {
    @Published var restaurant: AppRestaurant

    private let yelpService: YelpAPIService

    init(restaurant: AppRestaurant, yelpService: YelpAPIService) {
        self.restaurant = restaurant
        self.yelpService = yelpService
    }

    // Additional methods...
}
