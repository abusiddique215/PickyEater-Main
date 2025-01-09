import SwiftUI

struct RestaurantDetailView: View {
    let restaurant: AppRestaurant
    let yelpService: YelpAPIService
    @State private var imageURL: URL? = nil

    init(restaurant: AppRestaurant, yelpService: YelpAPIService) {
        self.restaurant = restaurant
        self.yelpService = yelpService
    }

    var body: some View {
        if let url = imageURL {
            AsyncImage(url: url) { image in
                image.resizable()
            } placeholder: {
                Image(systemName: "photo")
                    .resizable()
                    .frame(width: 100, height: 100)
            }
        } else {
            Image(systemName: "photo")
                .resizable()
                .frame(width: 100, height: 100)
        }
        // ...
    }
}
