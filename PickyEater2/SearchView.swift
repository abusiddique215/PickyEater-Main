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
            ScrollView {
                VStack(spacing: 24) {
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
                    if isSearching {
                        ProgressView("Searching...")
                            .padding()
                    } else {
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
                .padding(.vertical)
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        isSearching = false
                        searchText = ""
                    }
                }
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
                isSearching = false
            }
        } catch {
            print("Error during search: \(error)")
            DispatchQueue.main.async {
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