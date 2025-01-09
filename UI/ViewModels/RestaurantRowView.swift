import SwiftUI

struct RestaurantRowView: View {
    let restaurant: AppRestaurant
    let imageURL: URL? // Define the type explicitly

    var body: some View {
        HStack {
            if let url = imageURL {
                // Load image
                AsyncImage(url: url) { image in
                    image.resizable()
                } placeholder: {
                    Image(systemName: "photo")
                        .resizable()
                        .frame(width: 50, height: 50)
                }
                .frame(width: 50, height: 50)
            } else {
                // Placeholder image
                Image(systemName: "photo")
                    .resizable()
                    .frame(width: 50, height: 50)
            }
            // Other UI components...
            Text(restaurant.name)
        }
    }
}
