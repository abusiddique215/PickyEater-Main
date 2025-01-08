import SwiftUI

struct MainTabView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var preferencesManager = PreferencesManager()

    private let yelpService = YelpAPIService()
    private let filterService: RestaurantFilterService

    init() {
        filterService = RestaurantFilterService(preferencesManager: preferencesManager)
    }

    var body: some View {
        TabView {
            HomeView(
                yelpService: yelpService,
                locationManager: locationManager,
                filterService: filterService
            )
            .tabItem {
                Label("Home", systemImage: "house")
            }

            SearchView(
                yelpService: yelpService,
                locationManager: locationManager,
                filterService: filterService
            )
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }

            FavoritesView(
                yelpService: yelpService
            )
            .tabItem {
                Label("Favorites", systemImage: "heart")
            }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
        .environmentObject(locationManager)
        .environmentObject(preferencesManager)
        .onAppear {
            locationManager.requestWhenInUseAuthorization()
        }
    }
}

#Preview {
    MainTabView()
}
