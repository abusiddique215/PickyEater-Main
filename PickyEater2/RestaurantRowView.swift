import SwiftUI

struct RestaurantRowView: View {
    let restaurant: Restaurant
    let colors: (
        background: Color,
        primary: Color,
        secondary: Color,
        text: Color,
        cardBackground: Color,
        searchBackground: Color
    )
    
    var body: some View {
        HStack(spacing: 16) {
            // Restaurant Image
            AsyncImage(url: URL(string: restaurant.imageUrl)) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay {
                            ProgressView()
                                .tint(colors.primary)
                        }
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure(_):
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay {
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(colors.secondary)
                        }
                @unknown default:
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                }
            }
            .frame(width: 80, height: 80)
            .cornerRadius(8)
            
            // Restaurant Info
            VStack(alignment: .leading, spacing: 4) {
                Text(restaurant.name)
                    .font(.headline)
                    .foregroundColor(colors.text)
                
                if !restaurant.categories.isEmpty {
                    Text(restaurant.categories.map { $0.title }.joined(separator: " • "))
                        .font(.subheadline)
                        .foregroundColor(colors.secondary)
                        .lineLimit(1)
                }
                
                HStack {
                    if restaurant.rating > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", restaurant.rating))
                                .foregroundColor(colors.text)
                        }
                    }
                    
                    if let price = restaurant.price {
                        Text("•")
                            .foregroundColor(colors.secondary)
                        Text(price)
                            .foregroundColor(.green)
                    }
                    
                    if let distance = restaurant.distance {
                        Text("•")
                            .foregroundColor(colors.secondary)
                        Text(String(format: "%.1f km", distance / 1000))
                            .foregroundColor(colors.secondary)
                    }
                }
                .font(.caption)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(colors.secondary)
        }
        .padding()
        .background(colors.cardBackground)
        .cornerRadius(12)
    }
} 