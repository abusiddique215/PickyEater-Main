import SwiftUI
import CoreLocation

struct RestaurantListView: View {
    let preferences: UserPreferences
    let location: CLLocation
    let authorizationStatus: CLAuthorizationStatus
    
    @State private var restaurants: [Restaurant] = []
    @State private var isLoading = false
    @State private var error: Error?
    @State private var lastRequestTime: Date?
    
    // Minimum time between requests (5 seconds)
    private let requestThrottle: TimeInterval = 5
    
    // Initialize YelpAPIService with the API key
    private let yelpService: YelpAPIService = {
        let key = "66FqVibmo8LAv3zTD3fxxrzgkewb6uAJWBmkXQ5zQgu3PlC8sl0T2F7PuUdxXgZqdhr8NoXc9xueluXgbiGc1hFJqhu6Pnw2ZUXeM9EpxJEMmNuQt9JkOQmcZ6hxZ3Yx"
        print("Initializing YelpAPIService with key length: \(key.count)")
        return YelpAPIService(apiKey: key)
    }()
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView("Finding restaurants...")
            } else if let error = error {
                ErrorView(error: error) {
                    await loadRestaurants(force: true)
                }
            } else if restaurants.isEmpty {
                ContentUnavailableView("No Restaurants Found", 
                    systemImage: "fork.knife.circle",
                    description: Text("Try adjusting your preferences or increasing the search radius")
                )
            } else {
                restaurantList
            }
        }
        .navigationTitle("Nearby Restaurants")
        .task {
            await loadRestaurants()
        }
    }
    
    private var restaurantList: some View {
        List(restaurants) { restaurant in
            RestaurantRowView(restaurant: restaurant)
        }
        .refreshable {
            await loadRestaurants(force: true)
        }
    }
    
    private func loadRestaurants(force: Bool = false) async {
        // Check if we should throttle the request
        if !force, let lastRequest = lastRequestTime {
            let timeSinceLastRequest = Date().timeIntervalSince(lastRequest)
            if timeSinceLastRequest < requestThrottle {
                print("Request throttled. Time since last request: \(timeSinceLastRequest)s")
                return
            }
        }
        
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        lastRequestTime = Date()
        
        do {
            print("Loading restaurants for location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            print("Search radius: \(preferences.maxDistance) miles")
            print("Cuisine preferences: \(preferences.cuisinePreferences)")
            print("Price range: \(preferences.priceRange)")
            
            let radius = Int(preferences.maxDistance * 1609.34) // Convert miles to meters
            let newRestaurants = try await yelpService.searchRestaurants(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                categories: preferences.cuisinePreferences,
                price: preferences.priceRange,
                radius: radius
            )
            
            await MainActor.run {
                if newRestaurants.isEmpty {
                    error = NSError(
                        domain: "YelpAPI",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "No restaurants found matching your preferences. Try adjusting your filters."]
                    )
                } else {
                    restaurants = newRestaurants
                    error = nil
                }
                print("Found \(newRestaurants.count) restaurants")
            }
        } catch {
            print("Error loading restaurants: \(error.localizedDescription)")
            await MainActor.run {
                // Create a more user-friendly error message
                let errorMessage: String
                if let urlError = error as? URLError {
                    switch urlError.code {
                    case .notConnectedToInternet:
                        errorMessage = "No internet connection. Please check your connection and try again."
                    case .timedOut:
                        errorMessage = "Request timed out. Please try again."
                    default:
                        errorMessage = "Network error: \(urlError.localizedDescription)"
                    }
                } else {
                    errorMessage = "Failed to load restaurants. Please try again."
                }
                
                self.error = NSError(
                    domain: "YelpAPI",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: errorMessage]
                )
                self.restaurants = []
            }
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
                if let price = restaurant.price {
                    Text(price)
                        .foregroundColor(.secondary)
                    Text("•")
                        .foregroundColor(.secondary)
                }
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
    let retryAction: () async -> Void
    
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
                Task {
                    await retryAction()
                }
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
    let sampleRestaurant = Restaurant.sample
    return RestaurantDetailView(restaurant: sampleRestaurant)
        .navigationBarTitleDisplayMode(.inline)
} 