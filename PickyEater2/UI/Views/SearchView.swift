import SwiftUI
import MapKit
import PickyEater2Core

struct SearchView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var preferences: [UserPreferences]
    @StateObject private var locationManager = LocationManager()
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var recentSearches: [String] = []
    @State private var restaurants: [AppRestaurant] = []
    @State private var error: Error?
    @State private var showError = false
    
    private let searchDebouncer = Timer.publish(
        every: 0.5,
        on: .main,
        in: .common
    ).autoconnect()
    
    private var currentPreferences: UserPreferences {
        preferences.first ?? UserPreferences()
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if isSearching {
                    ProgressView("Searching...")
                        .progressViewStyle(.circular)
                } else if let error = error {
                    VStack(spacing: 16) {
                        Text("Error")
                            .font(.headline)
                        Text(error.localizedDescription)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        Button("Try Again") {
                            Task {
                                await searchRestaurants()
                            }
                        }
                    }
                    .padding()
                } else if restaurants.isEmpty {
                    ContentUnavailableView(
                        "No Results",
                        systemImage: "magnifyingglass",
                        description: Text("Try searching for a different location or cuisine")
                    )
                } else {
                    List(restaurants) { restaurant in
                        NavigationLink(value: restaurant) {
                            RestaurantRowView(restaurant: restaurant)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Search")
            .searchable(text: $searchText, prompt: "Search by location")
            .onReceive(searchDebouncer) { _ in
                guard !searchText.isEmpty else { return }
                Task {
                    await searchRestaurants()
                }
            }
            .navigationDestination(for: AppRestaurant.self) { restaurant in
                RestaurantDetailView(restaurant: restaurant)
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                if let error = error {
                    Text(error.localizedDescription)
                }
            }
        }
    }
    
    private func searchRestaurants() async {
        guard !searchText.isEmpty else {
            restaurants = []
            return
        }
        
        isSearching = true
        defer { isSearching = false }
        
        do {
            let results = try await YelpAPIService.shared.searchRestaurants(
                near: searchText,
                preferences: currentPreferences,
                radius: Int(currentPreferences.maxDistance * 1000)
            )
            restaurants = results
            if !recentSearches.contains(searchText) {
                recentSearches.append(searchText)
            }
        } catch {
            self.error = error
            showError = true
            restaurants = []
        }
    }
}

#Preview {
    SearchView()
        .modelContainer(for: UserPreferences.self, inMemory: true)
        .preferredColorScheme(.dark)
}
