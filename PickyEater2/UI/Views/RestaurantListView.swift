import MapKit
import PickyEater2Core
import SwiftUI

struct RestaurantListView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var preferencesManager = PreferencesManager.shared
    @State private var restaurants: [AppRestaurant] = []
    @State private var isLoading = false
    @State private var showError = false
    @State private var error: Error?
    @State private var showingMap = false

    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Finding restaurants...")
                } else if restaurants.isEmpty {
                    ContentUnavailableView(
                        "No Restaurants Found",
                        systemImage: "fork.knife.circle",
                        description: Text("Try adjusting your preferences or location")
                    )
                } else {
                    List(restaurants) { restaurant in
                        RestaurantRowView(restaurant: restaurant)
                    }
                }
            }
            .navigationTitle("Restaurants")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingMap = true
                    } label: {
                        Image(systemName: "map")
                    }
                }
            }
        }
        .sheet(isPresented: $showingMap) {
            if let location = locationManager.location {
                RestaurantMapView(
                    restaurants: restaurants,
                    centerCoordinate: location.coordinate
                )
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            if let error = error {
                Text(error.localizedDescription)
            }
        }
        .task {
            await loadRestaurants()
        }
        .refreshable {
            await loadRestaurants(forceRefresh: true)
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
        defer { isLoading = false }

        do {
            restaurants = try await YelpAPIService.shared.searchRestaurants(
                near: location,
                preferences: preferencesManager.userPreferences,
                forceRefresh: forceRefresh
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
    }
}

enum NetworkError: LocalizedError {
    case apiError(String)

    var errorDescription: String? {
        switch self {
        case let .apiError(message):
            return message
        }
    }
}
