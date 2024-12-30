import SwiftUI
import CoreLocation

struct RestaurantListView: View {
    let preferences: UserPreferences
    @State private var restaurants: [Restaurant] = []
    @State private var isLoading = false
    @State private var error: Error?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    Text("RECOMMENDED EATS (\(restaurants.count))")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button {
                        // Refresh restaurants
                    } label: {
                        Label("NEW SELECTION", systemImage: "arrow.clockwise")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.pink)
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal)
                
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                } else if let error = error {
                    ContentUnavailableView {
                        Label("Error Loading Restaurants", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(error.localizedDescription)
                    } actions: {
                        Button("Try Again") {
                            // Retry loading
                        }
                        .buttonStyle(.bordered)
                    }
                } else if restaurants.isEmpty {
                    ContentUnavailableView {
                        Label("No Restaurants Found", systemImage: "fork.knife")
                    } description: {
                        Text("Try adjusting your preferences or location")
                    }
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(restaurants) { restaurant in
                            RecommendedRestaurantCard(restaurant: restaurant)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .background(Color.black)
        .preferredColorScheme(.dark)
    }
}

struct RecommendedRestaurantCard: View {
    let restaurant: Restaurant
    @State private var isFavorite = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(restaurant.name)
                    .font(.title2)
                    .bold()
                Spacer()
                Button {
                    isFavorite.toggle()
                } label: {
                    Image(systemName: isFavorite ? "bookmark.fill" : "bookmark")
                        .foregroundColor(.white)
                }
            }
            
            HStack {
                Image(systemName: "location.fill")
                Text("Location: Downtown")
            }
            .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: "fork.knife")
                Text(restaurant.categories.map { $0.title }.joined(separator: ", "))
            }
            .foregroundColor(.secondary)
            
            if let photos = restaurant.photos, let firstPhoto = photos.first {
                AsyncImage(url: URL(string: firstPhoto)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            HStack(spacing: 12) {
                Button {
                    // Open in Maps
                } label: {
                    Text("FIND DIRECTIONS")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(8)
                }
                
                Button {
                    // Show more info
                } label: {
                    Text("MORE INFO")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(8)
                }
            }
            
            Text("Tap to see more options")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding()
        .background(Color.black)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

#Preview {
    RestaurantListView(preferences: UserPreferences())
        .preferredColorScheme(.dark)
} 