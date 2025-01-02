import SwiftUI
import CoreLocation

struct RestaurantListView: View {
    let preferences: UserPreferences
    @StateObject private var locationManager = LocationManager()
    @State private var restaurants: [Restaurant] = []
    @State private var isLoading = false
    @State private var error: Error?
    @State private var showingMap = false
    @Environment(\.appTheme) private var theme
    
    var body: some View {
        Group {
            switch locationManager.state {
            case .notDetermined, .unavailable:
                ContentUnavailableView {
                    Label("Requesting Location Access", systemImage: locationManager.state.systemImage)
                } description: {
                    Text(locationManager.state.description)
                }
            case .restricted, .denied:
                ContentUnavailableView {
                    Label("Location Access Required", systemImage: locationManager.state.systemImage)
                } description: {
                    Text(locationManager.state.description)
                } actions: {
                    Button("Open Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    .buttonStyle(.bordered)
                }
            case .authorized:
                if locationManager.location != nil {
                    restaurantList
                } else {
                    ProgressView("Getting your location...")
                }
            }
        }
        .background(theme == .dark ? Color.black : Color.white)
    }
    
    private var restaurantList: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    Text("RECOMMENDED EATS (\(restaurants.count))")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button {
                        showingMap.toggle()
                    } label: {
                        Label("Map View", systemImage: "map")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .clipShape(Capsule())
                    }
                    
                    Button {
                        Task {
                            await loadRestaurants(forceRefresh: true)
                        }
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
                            Task {
                                await loadRestaurants(forceRefresh: true)
                            }
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
        .sheet(isPresented: $showingMap) {
            if let location = locationManager.location {
                NavigationStack {
                    RestaurantMapView(
                        restaurants: restaurants,
                        centerCoordinate: location.coordinate
                    )
                    .navigationTitle("Nearby Restaurants")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") {
                                showingMap = false
                            }
                        }
                    }
                }
                .presentationDragIndicator(.visible)
            }
        }
        .task {
            await loadRestaurants()
        }
    }
    
    private func loadRestaurants(forceRefresh: Bool = false) async {
        guard !isLoading else { return }
        guard let location = locationManager.location else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            restaurants = try await YelpAPIService.shared.searchRestaurants(
                near: location,
                preferences: preferences
            )
        } catch {
            self.error = error
            restaurants = []
        }
    }
}

struct RecommendedRestaurantCard: View {
    let restaurant: Restaurant
    @State private var isFavorite = false
    @Environment(\.appTheme) private var theme
    
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
                Text("\(restaurant.location.address1), \(restaurant.location.city)")
            }
            .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text(String(format: "%.1f", restaurant.rating))
                Text("(\(restaurant.reviewCount) reviews)")
                    .foregroundColor(.secondary)
                if let price = restaurant.price {
                    Text("•")
                        .foregroundColor(.secondary)
                    Text(price)
                        .foregroundColor(.green)
                }
            }
            
            HStack {
                Image(systemName: "fork.knife")
                Text(restaurant.categories.map { $0.title }.joined(separator: ", "))
            }
            .foregroundColor(.secondary)
            
            if let firstPhoto = restaurant.photos.first {
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
            
            if let phone = restaurant.displayPhone {
                HStack {
                    Image(systemName: "phone.fill")
                    Text(phone)
                }
                .foregroundColor(.secondary)
            }
            
            HStack(spacing: 12) {
                Button {
                    // Open in Maps
                    let query = "\(restaurant.location.address1), \(restaurant.location.city)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                    if let url = URL(string: "maps://?q=\(query)") {
                        UIApplication.shared.open(url)
                    }
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
        .background(theme == .dark ? Color.black : Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(theme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.1), lineWidth: 1)
        )
    }
}

#Preview {
    RestaurantListView(preferences: UserPreferences())
        .preferredColorScheme(.dark)
} 