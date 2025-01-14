import SwiftUI
import Foundation

struct RestaurantRowView: View {
    let restaurant: AppRestaurant
    let imageURL: URL?

    var body: some View {
        HStack {
            if let url = imageURL {
                // Load image asynchronously
                AsyncImage(url: url) { image in
                    image.resizable()
                } placeholder: {
                    Image(systemName: "photo")
                        .resizable()
                        .frame(width: 50, height: 50)
                }
                .frame(width: 50, height: 50)
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .frame(width: 50, height: 50)
            }
            Text(restaurant.name)
        }
    }
}

#Preview {
    RestaurantRowView(
        restaurant: AppRestaurant(
            id: "1",
            name: "Sample Restaurant",
            distance: 1.5,
            priceRange: .twoDollars,
            categories: [Category(alias: "italian", title: "Italian")],
            imageUrl: ""
        ),
        imageURL: nil as URL?
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
