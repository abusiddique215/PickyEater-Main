import SwiftUI

struct RestaurantRowView: View {
    let restaurant: Restaurant
    
    var body: some View {
        HStack(spacing: 16) {
            // Restaurant Image
            if let imageURL = restaurant.imageURL {
                AsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color(.systemGray5)
                }
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: "fork.knife.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.secondary)
                    .frame(width: 80, height: 80)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            // Restaurant Info
            VStack(alignment: .leading, spacing: 4) {
                Text(restaurant.name)
                    .font(.headline)
                
                Text(restaurant.cuisineType)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    // Rating
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                        
                        Text(String(format: "%.1f", restaurant.rating))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Price Level
                    Text(restaurant.priceLevel)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }
}

#Preview {
    RestaurantRowView(
        restaurant: Restaurant(
            id: "1",
            name: "Sample Restaurant",
            cuisineType: "Italian",
            rating: 4.5,
            priceLevel: "$$$",
            imageURL: nil
        )
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
