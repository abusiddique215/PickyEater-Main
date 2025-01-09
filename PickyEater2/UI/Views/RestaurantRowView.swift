import SwiftUI

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
            cuisineType: "Italian",
            rating: 4.5,
            priceLevel: "$$$",
            imageURL: nil
        ),
        imageURL: nil
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
