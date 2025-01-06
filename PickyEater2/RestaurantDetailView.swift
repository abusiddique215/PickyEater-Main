import SwiftUI

struct RestaurantDetailView: View {
    let restaurant: Restaurant
    
    private let colors = (
        background: Color.black,
        primary: Color(red: 0.98, green: 0.24, blue: 0.25),
        secondary: Color(red: 0.97, green: 0.97, blue: 0.97),
        text: Color.white,
        cardBackground: Color(white: 0.12)
    )
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
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
                        EmptyView()
                    }
                }
                .frame(height: 250)
                .clipped()
                
                VStack(alignment: .leading, spacing: 16) {
                    // Restaurant Name and Rating
                    HStack {
                        Text(restaurant.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        if restaurant.rating > 0 {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text(String(format: "%.1f", restaurant.rating))
                            }
                        }
                    }
                    
                    // Categories and Price
                    HStack {
                        Text(restaurant.categories.map { $0.title }.joined(separator: " • "))
                            .font(.subheadline)
                            .foregroundColor(colors.secondary)
                        
                        if let price = restaurant.price {
                            Text("•")
                                .foregroundColor(colors.secondary)
                            Text(price)
                                .foregroundColor(.green)
                        }
                    }
                    
                    // Address
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(colors.primary)
                        Text(restaurant.location.address1)
                    }
                    .font(.subheadline)
                    
                    // Phone
                    if !restaurant.displayPhone.isEmpty {
                        Button {
                            if let url = URL(string: "tel:\(restaurant.phone)") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            HStack {
                                Image(systemName: "phone.fill")
                                    .foregroundColor(colors.primary)
                                Text(restaurant.displayPhone)
                            }
                        }
                        .font(.subheadline)
                    }
                }
                .padding()
            }
        }
        .background(colors.background)
        .navigationBarTitleDisplayMode(.inline)
    }
} 