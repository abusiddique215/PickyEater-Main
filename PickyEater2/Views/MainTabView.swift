import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var preferencesManager: PreferencesManager
    @EnvironmentObject var authService: AuthenticationService
    
    var body: some View {
        TabView {
            // Home Tab
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            // Search Tab
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            
            // Map Tab
            RestaurantMapView()
                .tabItem {
                    Label("Map", systemImage: "map.fill")
                }
            
            // Profile Tab
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .tint(Color(red: 0.98, green: 0.24, blue: 0.25)) // DoorDash red
    }
}

// MARK: - Home View

struct HomeView: View {
    @EnvironmentObject var preferencesManager: PreferencesManager
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Welcome Section
                    VStack(alignment: .leading, spacing: 8) {
                        if let user = AuthenticationService.shared.currentUser {
                            Text("Welcome back, \(user.name.components(separatedBy: " ").first ?? "there")! 👋")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        
                        Text("What would you like to eat today?")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    // Quick Filters
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(preferencesManager.preferences.cuisinePreferences, id: \.self) { cuisine in
                                Button {
                                    viewModel.selectedCuisine = cuisine
                                } label: {
                                    Text(cuisine)
                                        .font(.system(.subheadline, design: .rounded))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            Capsule()
                                                .fill(viewModel.selectedCuisine == cuisine ? Color(red: 0.98, green: 0.24, blue: 0.25) : Color(.systemGray6))
                                        )
                                        .foregroundColor(viewModel.selectedCuisine == cuisine ? .white : .primary)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Restaurant List
                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                    } else if viewModel.restaurants.isEmpty {
                        ContentUnavailableView(
                            "No Restaurants Found",
                            systemImage: "fork.knife.circle",
                            description: Text("Try adjusting your preferences or location")
                        )
                        .padding()
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.restaurants) { restaurant in
                                NavigationLink(value: restaurant) {
                                    RestaurantRowView(restaurant: restaurant)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationDestination(for: Restaurant.self) { restaurant in
                RestaurantDetailView(restaurant: restaurant)
            }
            .refreshable {
                await viewModel.fetchRestaurants()
            }
        }
        .task {
            await viewModel.fetchRestaurants()
        }
    }
}

// MARK: - Home View Model

@MainActor
class HomeViewModel: ObservableObject {
    @Published var restaurants: [Restaurant] = []
    @Published var isLoading = false
    @Published var selectedCuisine: String? {
        didSet {
            Task {
                await fetchRestaurants()
            }
        }
    }
    
    func fetchRestaurants() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // TODO: Implement actual restaurant fetching
            // This is just placeholder data
            restaurants = [
                Restaurant(id: "1", name: "Sample Restaurant 1", cuisineType: "Italian", rating: 4.5, priceLevel: "$$", imageURL: nil),
                Restaurant(id: "2", name: "Sample Restaurant 2", cuisineType: "Japanese", rating: 4.2, priceLevel: "$$$", imageURL: nil)
            ]
        } catch {
            print("Error fetching restaurants: \(error)")
            restaurants = []
        }
    }
}

// MARK: - Restaurant Model

struct Restaurant: Identifiable, Hashable {
    let id: String
    let name: String
    let cuisineType: String
    let rating: Double
    let priceLevel: String
    let imageURL: URL?
    
    static func == (lhs: Restaurant, rhs: Restaurant) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

#Preview {
    MainTabView()
        .environmentObject(PreferencesManager.shared)
        .environmentObject(AuthenticationService.shared)
}
