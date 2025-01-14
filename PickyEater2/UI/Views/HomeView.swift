import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @State private var showingPreferences = false
    @State private var showingRestaurantDetail = false

    init(
        yelpService: YelpAPIService,
        locationManager: LocationManager,
        filterService: RestaurantFilterService
    ) {
        _viewModel = StateObject(wrappedValue: HomeViewModel(
            yelpService: yelpService,
            locationManager: locationManager,
            filterService: filterService
        ))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading {
                    ProgressView("Finding restaurants...")
                        .progressViewStyle(.circular)
                } else if let error = viewModel.error {
                    ErrorView(error: error) {
                        Task {
                            await viewModel.refreshRestaurants()
                        }
                    }
                } else if viewModel.restaurants.isEmpty {
                    EmptyStateView()
                } else {
                    restaurantList
                }
            }
            .navigationTitle("PickyEater")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingPreferences = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                }
            }
            .sheet(isPresented: $showingPreferences) {
                PreferencesView()
            }
            .sheet(item: $viewModel.selectedRestaurant) { restaurant in
                NavigationStack {
                    RestaurantDetailView(
                        restaurant: restaurant,
                        yelpService: YelpAPIService()
                    )
                }
            }
            .refreshable {
                await viewModel.refreshRestaurants()
            }
        }
    }

    private var restaurantList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.restaurants) { restaurant in
                    RestaurantCard(restaurant: restaurant)
                        .onTapGesture {
                            viewModel.selectedRestaurant = restaurant
                        }
                }
            }
            .padding()
        }
    }
}

private struct RestaurantCard: View {
    let restaurant: Restaurant

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Restaurant Image
            AsyncImage(url: URL(string: restaurant.imageUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
            }
            .frame(height: 200)
            .clipped()
            .cornerRadius(12)

            // Restaurant Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(restaurant.name)
                        .font(.headline)
                    Spacer()
                    Text(String(repeating: "$", count: restaurant.priceRange.rawValue))
                        .foregroundColor(.green)
                }

                HStack {
                    RatingView(rating: restaurant.rating)
                    Text("(\(restaurant.reviewCount))")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }

                // Categories
                FlowLayout(spacing: 4) {
                    ForEach(restaurant.categories, id: \.self) { category in
                        Text(category)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                }

                // Distance and Status
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(.secondary)
                    Text(formatDistance(restaurant.distance))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(restaurant.isOpen ? "Open" : "Closed")
                        .foregroundColor(restaurant.isOpen ? .green : .red)
                }
                .font(.subheadline)
            }
            .padding(.horizontal, 8)
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 4)
    }

    private func formatDistance(_ distance: Double) -> String {
        let formatter = MeasurementFormatter()
        let measurement = Measurement(value: distance / 1000, unit: UnitLength.kilometers)
        return formatter.string(from: measurement)
    }
}

private struct ErrorView: View {
    let error: Error
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.red)

            Text("Oops!")
                .font(.title)
                .fontWeight(.bold)

            Text(error.localizedDescription)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)

            Button(action: retryAction) {
                Text("Try Again")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
        .padding()
    }
}

private struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "fork.knife.circle")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text("No Restaurants Found")
                .font(.title2)
                .fontWeight(.bold)

            Text("Try adjusting your preferences or location to find more restaurants.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

#Preview {
    HomeView(
        yelpService: YelpAPIService(),
        locationManager: LocationManager(),
        filterService: RestaurantFilterService(preferencesManager: PreferencesManager())
    )
}
