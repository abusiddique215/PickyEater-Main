import SwiftUI
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var featuredRestaurants: [Restaurant] = []
    @Published var nearbyRestaurants: [Restaurant] = []
    @Published var searchText = ""
    @Published var selectedCuisines: Set<String> = []
    @Published var selectedPriceLevels: Set<String> = []
    @Published var minimumRating: Double = 0
    @Published var isLoading = false
    @Published var error: Error?
    
    private let restaurantService: RestaurantService
    private var cancellables = Set<AnyCancellable>()
    
    init(restaurantService: RestaurantService = RestaurantService()) {
        self.restaurantService = restaurantService
        setupSearchPublisher()
        setupFilterPublishers()
        Task {
            await loadRestaurants()
        }
    }
    
    var filteredRestaurants: [Restaurant] {
        var restaurants = nearbyRestaurants
        
        // Apply search filter
        if !searchText.isEmpty {
            restaurants = restaurants.filter { restaurant in
                restaurant.name.localizedCaseInsensitiveContains(searchText) ||
                restaurant.cuisineType.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply cuisine filter
        if !selectedCuisines.isEmpty {
            restaurants = restaurants.filter { restaurant in
                selectedCuisines.contains(restaurant.cuisineType)
            }
        }
        
        // Apply price level filter
        if !selectedPriceLevels.isEmpty {
            restaurants = restaurants.filter { restaurant in
                selectedPriceLevels.contains(restaurant.priceLevel)
            }
        }
        
        // Apply rating filter
        if minimumRating > 0 {
            restaurants = restaurants.filter { restaurant in
                restaurant.rating >= minimumRating
            }
        }
        
        return restaurants
    }
    
    func loadRestaurants() async {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        do {
            async let featured = restaurantService.fetchFeaturedRestaurants()
            async let nearby = restaurantService.fetchNearbyRestaurants()
            
            let (featuredResult, nearbyResult) = await (try featured, try nearby)
            
            self.featuredRestaurants = featuredResult
            self.nearbyRestaurants = nearbyResult
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func refreshRestaurants() async {
        await loadRestaurants()
    }
    
    private func setupSearchPublisher() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    private func setupFilterPublishers() {
        Publishers.CombineLatest3($selectedCuisines, $selectedPriceLevels, $minimumRating)
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
}

// MARK: - Preview Helper

extension HomeViewModel {
    static var preview: HomeViewModel {
        let viewModel = HomeViewModel()
        viewModel.featuredRestaurants = Restaurant.samples
        viewModel.nearbyRestaurants = Restaurant.samples
        return viewModel
    }
} 