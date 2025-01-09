import SwiftUI

struct RestaurantRowView: View {
    let restaurant: AppRestaurant
    let imageURL: URL? // Define the type explicitly
    
    var body: some View {
        HStack {
            if let url = imageURL {
                // Load image
            } else {
                // Placeholder image
                Image(systemName: "photo")
                    .resizable()
                    .frame(width: 50, height: 50)
            }
            // Other UI components...
        }
    }
} 