import SwiftUI
import CoreLocation

struct RestaurantListView: View {
    let preferences: UserPreferences
    @StateObject private var locationManager = LocationManager()
    @State private var restaurants: [Restaurant] = []
    @State private var isLoading = false
    @State private var error: Error?
    @State private var showingMap = false
    @State private var showingProfile = false
    @Environment(\.appTheme) private var theme
    
    // Modern color scheme (matching CuisineSelectionView)
    private let colors = (
        background: Color.black,
        primary: Color(red: 0.98, green: 0.24, blue: 0.25),     // DoorDash red
        secondary: Color(red: 0.97, green: 0.97, blue: 0.97),   // Light gray
        text: Color.white,
        cardBackground: Color(white: 0.12)                       // Slightly lighter than black
    )
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch locationManager.state {
                case .notDetermined, .unavailable:
                    ContentUnavailableView {
                        Label("Requesting Location Access", systemImage: locationManager.state.systemImage)
                    } description: {
                        Text(locationManager.state.description)
                    }
                    .foregroundColor(colors.text)
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
                    .foregroundColor(colors.text)
                case .authorized:
                    if locationManager.location != nil {
                        restaurantList
                    } else {
                        ProgressView("Getting your location...")
                            .tint(colors.primary)
                            .foregroundColor(colors.text)
                    }
                }
            }
            .background(colors.background)
            
            // Bottom Navigation Bar
            HStack(spacing: 32) {
                NavigationBarButton(
                    title: "Home",
                    icon: "house.fill",
                    isActive: true,
                    color: colors.primary
                )
                
                NavigationBarButton(
                    title: "Search",
                    icon: "magnifyingglass",
                    isActive: false,
                    color: colors.primary
                )
                
                NavigationBarButton(
                    title: "Map",
                    icon: "map",
                    isActive: showingMap,
                    color: colors.primary
                ) {
                    showingMap.toggle()
                }
                
                NavigationBarButton(
                    title: "Profile",
                    icon: "person.fill",
                    isActive: showingProfile,
                    color: colors.primary
                ) {
                    showingProfile.toggle()
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                Rectangle()
                    .fill(colors.cardBackground)
                    .shadow(color: .black.opacity(0.2), radius: 10, y: -5)
            )
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text("Recommended")
                        .font(.headline)
                        .foregroundColor(colors.text)
                    if locationManager.location != nil {
                        Text("Near You")
                            .font(.caption)
                            .foregroundColor(colors.primary)
                    }
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        await loadRestaurants(forceRefresh: true)
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(colors.primary)
                }
            }
        }
        .sheet(isPresented: $showingProfile) {
            ProfileView()
        }
    }
    
    private var restaurantList: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Restaurant Cards
                LazyVStack(spacing: 24) {
                    ForEach(restaurants) { restaurant in
                        ModernRestaurantCard(restaurant: restaurant, colors: colors)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
        }
        .refreshable {
            await loadRestaurants(forceRefresh: true)
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

struct ModernRestaurantCard: View {
    let restaurant: Restaurant
    let colors: (
        background: Color,
        primary: Color,
        secondary: Color,
        text: Color,
        cardBackground: Color
    )
    @State private var isFavorite = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
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
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(alignment: .topTrailing) {
                Button {
                    isFavorite.toggle()
                } label: {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.title3)
                        .foregroundColor(isFavorite ? colors.primary : .white)
                        .padding(8)
                        .background(Circle().fill(Color.black.opacity(0.6)))
                        .padding(8)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                // Restaurant Name and Rating
                HStack {
                    Text(restaurant.name)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(colors.text)
                    
                    Spacer()
                    
                    if restaurant.rating > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", restaurant.rating))
                                .fontWeight(.semibold)
                                .foregroundColor(colors.text)
                            Text("(\(restaurant.reviewCount))")
                                .font(.caption)
                                .foregroundColor(colors.secondary)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(colors.cardBackground)
                        .cornerRadius(8)
                    }
                }
                
                // Categories and Price
                if !restaurant.categories.isEmpty {
                    HStack {
                        Text(restaurant.categories.map { $0.title }.joined(separator: " • "))
                            .font(.subheadline)
                            .foregroundColor(colors.secondary)
                            .lineLimit(1)
                        
                        if let price = restaurant.price {
                            Text("•")
                                .foregroundColor(colors.secondary)
                            Text(price)
                                .font(.subheadline)
                                .foregroundColor(.green)
                        }
                    }
                }
                
                // Location and Distance
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(colors.primary)
                    Text("\(restaurant.location.address1), \(restaurant.location.city)")
                        .font(.subheadline)
                        .foregroundColor(colors.secondary)
                    if let distance = restaurant.distance {
                        Text("•")
                            .foregroundColor(colors.secondary)
                        Text(String(format: "%.1f km", distance / 1000))
                            .font(.subheadline)
                            .foregroundColor(colors.secondary)
                    }
                }
                
                // Action Buttons
                HStack(spacing: 12) {
                    Button {
                        let query = "\(restaurant.location.address1), \(restaurant.location.city)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                        if let url = URL(string: "maps://?q=\(query)") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Label("Directions", systemImage: "location.fill")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(colors.text)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(colors.cardBackground)
                            .cornerRadius(12)
                    }
                    
                    if !restaurant.phone.isEmpty {
                        Button {
                            if let url = URL(string: "tel:\(restaurant.phone)") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            Label("Call", systemImage: "phone.fill")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(colors.text)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(colors.cardBackground)
                                .cornerRadius(12)
                        }
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .padding(16)
        .background(colors.cardBackground)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.2), radius: 8)
    }
}

struct NavigationBarButton: View {
    let title: String
    let icon: String
    let isActive: Bool
    let color: Color
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button {
            action?()
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(title)
                    .font(.caption2)
            }
            .foregroundColor(isActive ? color : .gray)
        }
    }
}

#Preview {
    RestaurantListView(preferences: UserPreferences())
        .preferredColorScheme(.dark)
} 