import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var searchText = ""
    @State private var showingFilters = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Featured Section
                    if !viewModel.featuredRestaurants.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Featured")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack(spacing: 16) {
                                    ForEach(viewModel.featuredRestaurants) { restaurant in
                                        NavigationLink(value: restaurant) {
                                            FeaturedRestaurantCard(restaurant: restaurant)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Nearby Section
                    VStack(alignment: .leading) {
                        Text("Nearby")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        ForEach(viewModel.filteredRestaurants) { restaurant in
                            NavigationLink(value: restaurant) {
                                RestaurantRowView(restaurant: restaurant)
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationDestination(for: Restaurant.self) { restaurant in
                RestaurantDetailView(restaurant: restaurant)
            }
            .navigationTitle("PickyEater")
            .searchable(text: $searchText, prompt: "Search restaurants")
            .onChange(of: searchText) { _, newValue in
                viewModel.searchText = newValue
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingFilters = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .sheet(isPresented: $showingFilters) {
                FilterView(
                    selectedCuisines: $viewModel.selectedCuisines,
                    selectedPriceLevels: $viewModel.selectedPriceLevels,
                    minimumRating: $viewModel.minimumRating
                )
                .presentationDetents([.medium])
            }
        }
    }
}

// MARK: - Featured Restaurant Card

struct FeaturedRestaurantCard: View {
    let restaurant: Restaurant
    
    var body: some View {
        VStack(alignment: .leading) {
            // Restaurant Image
            if let imageURL = restaurant.imageURL {
                AsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color(.systemGray5)
                }
                .frame(height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                Color(.systemGray6)
                    .frame(height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay {
                        Image(systemName: "fork.knife.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                    }
            }
            
            // Restaurant Info
            VStack(alignment: .leading, spacing: 4) {
                Text(restaurant.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(restaurant.cuisineType)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text(String(format: "%.1f", restaurant.rating))
                    Text("•")
                    Text(restaurant.priceLevel)
                        .foregroundColor(.green)
                }
                .font(.caption)
            }
            .padding(.vertical, 8)
        }
        .frame(width: 250)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }
}

// MARK: - Filter View

struct FilterView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedCuisines: Set<String>
    @Binding var selectedPriceLevels: Set<String>
    @Binding var minimumRating: Double
    
    private let cuisineTypes = ["Italian", "Japanese", "Mexican", "Chinese", "Indian", "Thai", "American", "French"]
    private let priceLevels = ["$", "$$", "$$$", "$$$$"]
    
    var body: some View {
        NavigationStack {
            Form {
                // Cuisine Types
                Section("Cuisine Types") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(cuisineTypes, id: \.self) { cuisine in
                                FilterChip(
                                    title: cuisine,
                                    isSelected: selectedCuisines.contains(cuisine)
                                ) {
                                    if selectedCuisines.contains(cuisine) {
                                        selectedCuisines.remove(cuisine)
                                    } else {
                                        selectedCuisines.insert(cuisine)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                // Price Levels
                Section("Price Level") {
                    HStack {
                        ForEach(priceLevels, id: \.self) { price in
                            FilterChip(
                                title: price,
                                isSelected: selectedPriceLevels.contains(price)
                            ) {
                                if selectedPriceLevels.contains(price) {
                                    selectedPriceLevels.remove(price)
                                } else {
                                    selectedPriceLevels.insert(price)
                                }
                            }
                        }
                    }
                }
                
                // Minimum Rating
                Section("Minimum Rating") {
                    HStack {
                        Slider(value: $minimumRating, in: 0...5, step: 0.5)
                        Text(String(format: "%.1f", minimumRating))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        selectedCuisines.removeAll()
                        selectedPriceLevels.removeAll()
                        minimumRating = 0
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentColor : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}

#Preview {
    HomeView()
}
