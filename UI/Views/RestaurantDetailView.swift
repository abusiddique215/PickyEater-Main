import SwiftUI

struct RestaurantDetailView: View {
    let restaurant: AppRestaurant
    let yelpService: YelpAPIService
    let imageURL: URL?
    
    init(restaurant: AppRestaurant, yelpService: YelpAPIService) {
        self.restaurant = restaurant
        self.yelpService = yelpService
        self.imageURL = nil
    }
    
    var body: some View {
        if let url = imageURL {
            // Display image
        } else {
            // Placeholder
        }
    }
} 