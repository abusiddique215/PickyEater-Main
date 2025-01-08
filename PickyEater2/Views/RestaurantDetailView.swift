import SwiftUI

struct RestaurantDetailView: View {
    let restaurant: Restaurant
    @Environment(\.dismiss) private var dismiss
    @State private var showShareSheet = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header Image
                if let imageURL = restaurant.imageURL {
                    AsyncImage(url: imageURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color(.systemGray5)
                    }
                    .frame(height: 250)
                    .clipped()
                } else {
                    Color(.systemGray6)
                        .frame(height: 250)
                        .overlay {
                            Image(systemName: "fork.knife.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.secondary)
                        }
                }
                
                // Content
                VStack(spacing: 24) {
                    // Restaurant Info
                    VStack(alignment: .leading, spacing: 8) {
                        Text(restaurant.name)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(restaurant.cuisineType)
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 16) {
                            // Rating
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text(String(format: "%.1f", restaurant.rating))
                            }
                            
                            // Price Level
                            Text(restaurant.priceLevel)
                                .foregroundColor(.green)
                        }
                        .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Action Buttons
                    HStack(spacing: 16) {
                        // Call Button
                        Button {
                            // TODO: Implement call action
                        } label: {
                            VStack {
                                Image(systemName: "phone.fill")
                                    .font(.title3)
                                Text("Call")
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        // Share Button
                        Button {
                            showShareSheet = true
                        } label: {
                            VStack {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.title3)
                                Text("Share")
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        // Directions Button
                        Button {
                            // TODO: Implement directions action
                        } label: {
                            VStack {
                                Image(systemName: "location.fill")
                                    .font(.title3)
                                Text("Directions")
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .foregroundColor(.primary)
                    
                    // Order Button
                    Button {
                        // TODO: Implement order action
                    } label: {
                        Text("Order Now")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(red: 0.98, green: 0.24, blue: 0.25)) // DoorDash red
                            .cornerRadius(12)
                    }
                }
                .padding()
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    // TODO: Implement favorite action
                } label: {
                    Image(systemName: "heart")
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = URL(string: "https://pickyeater.app/restaurant/\(restaurant.id)") {
                ShareSheet(items: [url])
            }
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        RestaurantDetailView(
            restaurant: Restaurant(
                id: "1",
                name: "Sample Restaurant",
                cuisineType: "Italian",
                rating: 4.5,
                priceLevel: "$$$",
                imageURL: nil
            )
        )
    }
}
