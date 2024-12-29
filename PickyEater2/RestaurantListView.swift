import SwiftUI
import CoreLocation

struct RestaurantListView: View {
    let preferences: UserPreferences
    let location: CLLocation?
    
    @State private var restaurants: [Restaurant] = []
    @State private var isLoading = false
    @State private var error: Error?
    
    private let yelpService = YelpAPIService(apiKey: "YOUR_YELP_API_KEY") // Replace with your API key
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Finding restaurants...")
                } else if let error = error {
                    ErrorView(error: error, retryAction: loadRestaurants)
                } else {
                    restaurantList
                }
            }
            .navigationTitle("Nearby Restaurants")
            .task {
                await loadRestaurants()
            }
        }
    }
    
    private var restaurantList: some View {
        List(restaurants) { restaurant in
            NavigationLink(destination: RestaurantDetailView(restaurant: restaurant)) {
                RestaurantRowView(restaurant: restaurant)
            }
        }
        .refreshable {
            await loadRestaurants()
        }
    }
    
    private func loadRestaurants() async {
        guard let location = location else {
            error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Location not available"])
            return
        }
        
        isLoading = true
        error = nil
        
        do {
            let radius = Int(preferences.maxDistance * 1609.34) // Convert miles to meters
            restaurants = try await yelpService.searchRestaurants(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                categories: preferences.cuisinePreferences,
                price: preferences.priceRange,
                radius: radius
            )
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
}

struct RestaurantRowView: View {
    let restaurant: Restaurant
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(restaurant.name)
                .font(.headline)
            
            HStack {
                Text(restaurant.price ?? "")
                    .foregroundColor(.secondary)
                Text("•")
                    .foregroundColor(.secondary)
                Text(String(format: "%.1f", restaurant.rating))
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
            }
            
            Text(restaurant.location.address1)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

struct ErrorView: View {
    let error: Error
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text("😕")
                .font(.system(size: 64))
            Text("Something went wrong")
                .font(.headline)
            Text(error.localizedDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Button("Try Again") {
                retryAction()
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

struct RestaurantDetailView: View {
    let restaurant: Restaurant
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let photos = restaurant.photos, let firstPhoto = photos.first {
                    AsyncImage(url: URL(string: firstPhoto)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .foregroundColor(.gray.opacity(0.2))
                    }
                    .frame(height: 200)
                    .clipped()
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(restaurant.name)
                        .font(.title)
                        .bold()
                    
                    HStack {
                        Text(restaurant.price ?? "")
                        Text("•")
                        Text("\(restaurant.rating, specifier: "%.1f")")
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                    }
                    .foregroundColor(.secondary)
                    
                    Text(restaurant.location.address1)
                    Text("\(restaurant.location.city), \(restaurant.location.state) \(restaurant.location.zipCode)")
                    
                    if !restaurant.categories.isEmpty {
                        Text(restaurant.categories.map { $0.title }.joined(separator: ", "))
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                    
                    Link(destination: URL(string: "https://www.yelp.com/biz/\(restaurant.id)")!) {
                        HStack {
                            Text("View on Yelp")
                            Image(systemName: "arrow.up.right.square")
                        }
                    }
                    .buttonStyle(.bordered)
                    .padding(.top, 8)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let sampleRestaurant = Restaurant(
        id: "sample",
        name: "Sample Restaurant",
        rating: 4.5,
        price: "$$",
        location: Restaurant.Location(
            address1: "123 Main St",
            city: "San Francisco",
            state: "CA",
            zipCode: "94105"
        ),
        photos: nil,
        categories: [
            Restaurant.Category(alias: "american", title: "American")
        ],
        coordinates: Restaurant.Coordinates(latitude: 37.7749, longitude: -122.4194),
        isClosed: false
    )
    
    return RestaurantDetailView(restaurant: sampleRestaurant)
} 