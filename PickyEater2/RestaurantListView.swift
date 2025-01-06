import SwiftUI
import CoreLocation

struct RestaurantListView: View {
    let preferences: UserPreferences
    let searchQuery: String
    
    init(preferences: UserPreferences, searchQuery: String = "") {
        self.preferences = preferences
        self.searchQuery = searchQuery
    }
    
    @StateObject private var locationManager = LocationManager()
    @State private var restaurants: [Restaurant] = []
    @State private var isLoading = false
    @State private var error: Error?
    @State private var showError = false
    @State private var showingMap = false
    @State private var showingProfile = false
    @State private var showingPreferences = false
    @Environment(\.appTheme) private var theme
    
    private let colors = (
        background: Color.black,
        primary: Color(red: 0.98, green: 0.24, blue: 0.25),
        secondary: Color(red: 0.97, green: 0.97, blue: 0.97),
        text: Color.white,
        cardBackground: Color(white: 0.12)
    )
    
    var body: some View {
        ZStack {
            colors.background
                .ignoresSafeArea()
            
            if isLoading {
                ProgressView()
                    .tint(colors.primary)
            } else if !restaurants.isEmpty {
                ScrollView {
                    LazyVStack(spacing: 20) {
                        ForEach(restaurants) { restaurant in
                            NavigationLink(destination: RestaurantDetailView(restaurant: restaurant)) {
                                ModernRestaurantCard(restaurant: restaurant, colors: colors)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
            } else if let error = error {
                ErrorView(error: error) {
                    Task {
                        await loadRestaurants(forceRefresh: true)
                    }
                }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "fork.knife.circle")
                        .font(.system(size: 50))
                        .foregroundColor(colors.primary)
                    Text("No restaurants found")
                        .font(.title2)
                        .foregroundColor(colors.text)
                    Text("Try adjusting your preferences or search criteria")
                        .font(.subheadline)
                        .foregroundColor(colors.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingMap = true
                } label: {
                    Image(systemName: "map")
                        .foregroundColor(colors.text)
                }
            }
        }
        .sheet(isPresented: $showingMap) {
            if let location = locationManager.location {
                RestaurantMapView(
                    restaurants: restaurants,
                    centerCoordinate: location.coordinate
                )
                .presentationDragIndicator(.visible)
            }
        }
        .alert("Error", isPresented: $showError, presenting: error) { _ in
            Button("OK") { }
            Button("Retry") {
                Task {
                    await loadRestaurants(forceRefresh: true)
                }
            }
        } message: { error in
            Text(error.localizedDescription)
        }
        .task {
            await loadRestaurants()
        }
    }
    
    private func loadRestaurants(forceRefresh: Bool = false) async {
        guard !isLoading else { return }
        guard let location = locationManager.location else {
            error = NetworkError.apiError("Location services are not available")
            showError = true
            return
        }
        
        isLoading = true
        error = nil
        
        do {
            restaurants = try await YelpAPIService.shared.searchRestaurants(
                near: location,
                preferences: preferences,
                searchQuery: searchQuery
            )
            if restaurants.isEmpty {
                error = NetworkError.apiError("No restaurants found matching your criteria")
            }
        } catch let networkError as NetworkError {
            error = networkError
            showError = true
            restaurants = []
        } catch {
            self.error = NetworkError.apiError(error.localizedDescription)
            showError = true
            restaurants = []
        }
        
        isLoading = false
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