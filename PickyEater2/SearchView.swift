import SwiftUI
import SwiftData

struct SearchView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var preferences: [UserPreferences]
    @StateObject private var locationManager = LocationManager()
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var recentSearches: [String] = []
    @State private var restaurants: [Restaurant] = []
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
    
    private var currentPreferences: UserPreferences {
        preferences.first ?? UserPreferences()
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                colors.background
                    .ignoresSafeArea()
                
                VStack {
                    // Search Bar
                    SearchBar(text: $searchText, isSearching: $isSearching, colors: colors)
                        .padding(.horizontal)
                    
                    if isSearching {
                        ProgressView()
                            .tint(colors.primary)
                    } else if let error = error {
                        ErrorView(error: error) {
                            Task {
                                await loadSearchResults()
                            }
                        }
                    } else {
                        // Recent Searches
                        if !recentSearches.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Recent Searches")
                                    .font(.headline)
                                    .foregroundColor(colors.text)
                                    .padding(.horizontal)
                                
                                ForEach(recentSearches, id: \.self) { search in
                                    Button(action: {
                                        searchText = search
                                        performSearch()
                                    }) {
                                        HStack {
                                            Image(systemName: "clock")
                                                .foregroundColor(colors.secondary)
                                            Text(search)
                                                .foregroundColor(colors.text)
                                            Spacer()
                                            Image(systemName: "arrow.right")
                                                .foregroundColor(colors.primary)
                                        }
                                        .padding(.horizontal)
                                        .padding(.vertical, 8)
                                        .background(colors.cardBackground)
                                        .cornerRadius(10)
                                    }
                                }
                            }
                            .padding(.top)
                        }
                        
                        // Search Results
                        if !restaurants.isEmpty {
                            ForEach(restaurants) { restaurant in
                                NavigationLink(destination: RestaurantDetailView(restaurant: restaurant)) {
                                    RestaurantRowView(restaurant: restaurant, colors: colors)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.horizontal)
                            }
                        } else {
                            Text("No results found.")
                                .foregroundColor(colors.secondary)
                                .padding()
                        }
                    }
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Error", isPresented: $showError, presenting: error) { _ in
                Button("OK") { }
                Button("Retry") {
                    Task {
                        await loadSearchResults()
                    }
                }
            } message: { error in
                Text(error.localizedDescription)
            }
            .onSubmit(of: .search) {
                performSearch()
            }
        }
    }
    
    private func performSearch() {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isSearching = true
        // Add searchText to recent searches
        if !recentSearches.contains(searchText) {
            recentSearches.insert(searchText, at: 0)
        }
        
        Task {
            await loadSearchResults()
        }
    }
    
    private func loadSearchResults() async {
        guard let location = locationManager.location else {
            error = NetworkError.apiError("Location services are not available")
            showError = true
            isSearching = false
            return
        }
        
        do {
            let results = try await YelpAPIService.shared.searchRestaurants(
                near: location,
                preferences: currentPreferences,
                searchQuery: searchText
            )
            
            DispatchQueue.main.async {
                restaurants = results
                if results.isEmpty {
                    error = NetworkError.apiError("No restaurants found matching '\(searchText)'")
                    showError = true
                }
                isSearching = false
            }
        } catch let networkError as NetworkError {
            DispatchQueue.main.async {
                error = networkError
                showError = true
                restaurants = []
                isSearching = false
            }
        } catch {
            DispatchQueue.main.async {
                self.error = NetworkError.apiError(error.localizedDescription)
                showError = true
                restaurants = []
                isSearching = false
            }
        }
    }
}

#Preview {
    SearchView()
        .modelContainer(for: UserPreferences.self, inMemory: true)
        .preferredColorScheme(.dark)
} 