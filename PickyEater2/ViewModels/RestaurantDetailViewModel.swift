import Foundation
import Combine
import MapKit

@MainActor
class RestaurantDetailViewModel: ObservableObject {
    @Published var restaurant: Restaurant
    @Published var isLoading = false
    @Published var error: Error?
    @Published var isFavorite = false
    @Published var reviews: [Review] = []
    @Published var region: MKCoordinateRegion
    
    private let yelpService: YelpAPIService
    private var cancellables = Set<AnyCancellable>()
    
    init(restaurant: Restaurant, yelpService: YelpAPIService) {
        self.restaurant = restaurant
        self.yelpService = yelpService
        
        // Initialize map region centered on restaurant
        self.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: restaurant.coordinates.latitude,
                longitude: restaurant.coordinates.longitude
            ),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        
        // Load initial data
        Task {
            await loadReviews()
            checkFavoriteStatus()
        }
    }
    
    func loadReviews() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            reviews = try await yelpService.fetchReviews(for: restaurant.id)
        } catch {
            self.error = error
        }
    }
    
    func toggleFavorite() {
        isFavorite.toggle()
        // Update UserDefaults or persistent storage
        if isFavorite {
            saveFavorite()
        } else {
            removeFavorite()
        }
    }
    
    private func checkFavoriteStatus() {
        // Check if restaurant is in favorites
        let defaults = UserDefaults.standard
        let favorites = defaults.array(forKey: "FavoriteRestaurants") as? [String] ?? []
        isFavorite = favorites.contains(restaurant.id)
    }
    
    private func saveFavorite() {
        var favorites = UserDefaults.standard.array(forKey: "FavoriteRestaurants") as? [String] ?? []
        if !favorites.contains(restaurant.id) {
            favorites.append(restaurant.id)
            UserDefaults.standard.set(favorites, forKey: "FavoriteRestaurants")
        }
    }
    
    private func removeFavorite() {
        var favorites = UserDefaults.standard.array(forKey: "FavoriteRestaurants") as? [String] ?? []
        favorites.removeAll { $0 == restaurant.id }
        UserDefaults.standard.set(favorites, forKey: "FavoriteRestaurants")
    }
    
    func getDirections() {
        let coordinates = CLLocationCoordinate2D(
            latitude: restaurant.coordinates.latitude,
            longitude: restaurant.coordinates.longitude
        )
        let placemark = MKPlacemark(coordinate: coordinates)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = restaurant.name
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
    
    func share() {
        // Implementation for sharing restaurant details
        // This would typically use UIActivityViewController in the View layer
    }
} 