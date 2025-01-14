import SwiftUI
import PickyEater2Core

struct RestaurantRowView: View {
    let restaurant: AppRestaurant
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: restaurant.imageUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(restaurant.name)
                    .font(.headline)
                
                HStack {
                    ForEach(restaurant.categories, id: \.alias) { category in
                        Text(category.title)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack {
                    Text(String(format: "%.1f km", restaurant.distance))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(restaurant.priceRange.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    RestaurantRowView(restaurant: AppRestaurant(
        id: "1",
        name: "Sample Restaurant",
        distance: 1.5,
        priceRange: .twoDollars,
        categories: [Category(alias: "italian", title: "Italian")],
        imageUrl: ""
    ))
    .padding()
    .background(Color(uiColor: .systemGroupedBackground))
}
