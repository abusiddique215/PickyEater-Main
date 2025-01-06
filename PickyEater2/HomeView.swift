import SwiftUI
import CoreLocation

// 1. Create two separate category models
struct StoreCategory: Identifiable {
    let id = UUID()
    let name: String
    let iconName: String
    let type: String // To differentiate between store and food category
    
    static let stores = [
        StoreCategory(name: "King's Teriyaki", iconName: "kings_logo", type: "store"),
        StoreCategory(name: "Burger King", iconName: "bk_logo", type: "store"),
        StoreCategory(name: "McDonald's", iconName: "mcdonalds_logo", type: "store"),
        StoreCategory(name: "Subway", iconName: "subway_logo", type: "store"),
        StoreCategory(name: "Domino's", iconName: "dominos_logo", type: "store")
    ]
    
    static let foodCategories = [
        StoreCategory(name: "Sushi", iconName: "circle.grid.2x2.fill", type: "food"),
        StoreCategory(name: "Pizza", iconName: "triangle.fill", type: "food"),
        StoreCategory(name: "Halal", iconName: "moon.fill", type: "food"),
        StoreCategory(name: "Chinese", iconName: "takeoutbag.and.cup.and.straw.fill", type: "food"),
        StoreCategory(name: "Thai", iconName: "leaf.fill", type: "food")
    ]
}

// 2. Create a reusable horizontal scroll section
struct CategoryScrollSection: View {
    let title: String
    let categories: [StoreCategory]
    let colors: (
        background: Color,
        primary: Color,
        secondary: Color,
        text: Color,
        cardBackground: Color,
        searchBackground: Color
    )
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(colors.text)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(categories) { category in
                        CategoryCircle(category: category, colors: colors)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
            }
        }
        .padding(.top, 5)
    }
}

// 3. Create a unified circle view for both types
struct CategoryCircle: View {
    let category: StoreCategory
    let colors: (
        background: Color,
        primary: Color,
        secondary: Color,
        text: Color,
        cardBackground: Color,
        searchBackground: Color
    )
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color(white: 0.15))
                    .frame(width: 65, height: 65)
                    .shadow(color: .black.opacity(0.2), radius: 2)
                
                if category.type == "store" {
                    // Replace Image(category.iconName) with a placeholder SF Symbol if image not available
                    Image(systemName: "building.2.crop.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                } else {
                    // For food categories, use SF Symbols
                    Image(systemName: category.iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white)
                }
            }
            
            Text(category.name)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(colors.text)
                .lineLimit(1)
        }
        .frame(width: 75)
    }
}

struct HomeView: View {
    let preferences: UserPreferences
    @StateObject private var locationManager = LocationManager()
    @State private var searchText = ""
    @State private var featuredRestaurants: [Restaurant] = []
    @State private var isLoading = false
    @State private var storesNearYou: [Restaurant] = []
    @State private var error: NetworkError?
    @State private var showError = false
    
    // Modern color scheme (matching our theme)
    private let colors = (
        background: Color.black,
        primary: Color(red: 0.98, green: 0.24, blue: 0.25),     // DoorDash red
        secondary: Color(red: 0.97, green: 0.97, blue: 0.97),   // Light gray
        text: Color.white,
        cardBackground: Color(white: 0.12),                      // Slightly lighter than black
        searchBackground: Color(white: 0.08)                     // Even darker for search bar
    )
    
    var body: some View {
        ZStack {
            colors.background
                .ignoresSafeArea()
            
            if isLoading {
                ProgressView()
                    .tint(colors.primary)
            } else if let error = error {
                ErrorView(error: error) {
                    Task {
                        await loadFeaturedRestaurants()
                        await loadStoresNearYou()
                    }
                }
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        // Location and Profile Header
                        HStack {
                            // Location Button
                            Button {
                                // Handle location selection
                            } label: {
                                HStack {
                                    if let address = locationManager.address {
                                        Text(address)
                                            .font(.headline)
                                            .foregroundColor(colors.text)
                                    } else {
                                        Text("Set Location")
                                            .font(.headline)
                                            .foregroundColor(colors.text)
                                    }
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(colors.primary)
                                }
                            }
                            
                            Spacer()
                            
                            // Profile Button
                            Button {
                                // Handle profile
                            } label: {
                                Image(systemName: "person.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(colors.primary)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Search Bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(Color.gray)
                            TextField("Search for restaurants", text: $searchText)
                                .foregroundColor(colors.text)
                        }
                        .padding()
                        .background(colors.searchBackground)
                        .cornerRadius(15)
                        .padding(.horizontal)
                        
                        // Stores Near You Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Stores near you")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(colors.text)
                                .padding(.horizontal)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(storesNearYou) { store in
                                        VStack(spacing: 8) {
                                            ZStack {
                                                Circle()
                                                    .fill(Color(white: 0.15))
                                                    .frame(width: 65, height: 65)
                                                    .shadow(color: .black.opacity(0.2), radius: 2)

                                                AsyncImage(url: URL(string: store.imageUrl)) { phase in
                                                    switch phase {
                                                    case .empty:
                                                        ProgressView()
                                                            .tint(colors.primary)
                                                    case .success(let image):
                                                        image
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 40, height: 40)
                                                            .clipShape(Circle())
                                                    case .failure(_):
                                                        Image(systemName: "photo")
                                                            .font(.largeTitle)
                                                            .foregroundColor(colors.secondary)
                                                    @unknown default:
                                                        EmptyView()
                                                    }
                                                }
                                            }
                                            Text(store.name)
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(colors.text)
                                                .lineLimit(1)
                                        }
                                        .frame(width: 75)
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 5)
                            }
                        }
                        .padding(.top, 5)
                        
                        // Food Categories Section
                        CategoryScrollSection(
                            title: "Food Categories",
                            categories: StoreCategory.foodCategories,
                            colors: colors
                        )
                        
                        // Featured Restaurants Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Featured on Picky Eater")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(colors.text)
                                
                                Spacer()
                                
                                Button {
                                    // Handle see all
                                } label: {
                                    Text("See All")
                                        .font(.subheadline)
                                        .foregroundColor(colors.primary)
                                }
                            }
                            .padding(.horizontal)
                            
                            if isLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(featuredRestaurants) { restaurant in
                                            FeaturedRestaurantCard(restaurant: restaurant, colors: colors)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        
                        // Places You Might Like Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Places you might like")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(colors.text)
                                
                                Spacer()
                                
                                Button("See All") {
                                    // Handle see all
                                }
                                .foregroundColor(colors.primary)
                            }
                            .padding(.horizontal)
                            
                            if isLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(featuredRestaurants.prefix(5)) { restaurant in
                                            RecentOrderCard(restaurant: restaurant, colors: colors)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .alert("Error", isPresented: $showError, presenting: error) { _ in
            Button("OK") { }
            Button("Retry") {
                Task {
                    await loadFeaturedRestaurants()
                    await loadStoresNearYou()
                }
            }
        } message: { error in
            Text(error.localizedDescription)
        }
        .task {
            await loadFeaturedRestaurants()
            await loadStoresNearYou()
        }
    }
    
    private func loadFeaturedRestaurants() async {
        guard !isLoading else { return }
        guard let location = locationManager.location else {
            error = NetworkError.apiError("Location services are not available")
            showError = true
            return
        }
        
        isLoading = true
        error = nil
        
        do {
            featuredRestaurants = try await YelpAPIService.shared.searchRestaurants(
                near: location,
                preferences: preferences
            )
            if featuredRestaurants.isEmpty {
                error = NetworkError.apiError("No restaurants found matching your criteria")
            }
        } catch let networkError as NetworkError {
            error = networkError
            showError = true
            featuredRestaurants = []
        } catch {
            self.error = NetworkError.apiError(error.localizedDescription)
            showError = true
            featuredRestaurants = []
        }
        
        isLoading = false
    }
    
    private func loadStoresNearYou() async {
        guard let location = locationManager.location else {
            error = NetworkError.apiError("Location services are not available")
            showError = true
            return
        }
        
        do {
            self.storesNearYou = try await YelpAPIService.shared.searchRestaurants(
                near: location,
                preferences: preferences
            )
            if storesNearYou.isEmpty {
                error = NetworkError.apiError("No stores found near you")
            }
        } catch let networkError as NetworkError {
            error = networkError
            showError = true
            storesNearYou = []
        } catch {
            self.error = NetworkError.apiError(error.localizedDescription)
            showError = true
            storesNearYou = []
        }
    }
}

// Update FeaturedRestaurantCard to use actual restaurant data
struct FeaturedRestaurantCard: View {
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
        VStack(alignment: .leading, spacing: 8) {
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
            .frame(width: 250, height: 150)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Restaurant Info
            VStack(alignment: .leading, spacing: 4) {
                Text(restaurant.name)
                    .font(.headline)
                    .foregroundColor(colors.text)
                
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text(String(format: "%.1f", restaurant.rating))
                        .foregroundColor(colors.text)
                    Text("(\(restaurant.reviewCount))")
                        .foregroundColor(colors.secondary)
                    Text("•")
                        .foregroundColor(colors.secondary)
                    if let distance = restaurant.distance {
                        Text(String(format: "%.1f km", distance / 1000))
                            .foregroundColor(colors.secondary)
                    }
                }
                .font(.caption)
            }
            .padding(.horizontal, 4)
        }
        .frame(width: 250)
        .background(colors.cardBackground)
        .cornerRadius(16)
    }
}

// Update RecentOrderCard to use actual restaurant data
struct RecentOrderCard: View {
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
        VStack(alignment: .leading, spacing: 8) {
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
            .frame(width: 200, height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Restaurant Info
            VStack(alignment: .leading, spacing: 4) {
                Text(restaurant.name)
                    .font(.headline)
                    .foregroundColor(colors.text)
                
                if let distance = restaurant.distance {
                    Text(String(format: "%.1f km", distance / 1000))
                        .font(.caption)
                        .foregroundColor(colors.secondary)
                }
            }
            .padding(.horizontal, 4)
        }
        .frame(width: 200)
        .background(colors.cardBackground)
        .cornerRadius(16)
    }
}

#Preview {
    HomeView(preferences: UserPreferences())
        .preferredColorScheme(.dark)
} 