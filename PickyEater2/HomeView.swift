import SwiftUI
import CoreLocation

struct HomeView: View {
    let preferences: UserPreferences
    @StateObject private var locationManager = LocationManager()
    @State private var searchText = ""
    
    // Modern color scheme (matching our theme)
    private let colors = (
        background: Color.black,
        primary: Color(red: 0.98, green: 0.24, blue: 0.25),     // DoorDash red
        secondary: Color(red: 0.97, green: 0.97, blue: 0.97),   // Light gray
        text: Color.white,
        cardBackground: Color(white: 0.12),                      // Slightly lighter than black
        searchBackground: Color(white: 0.08)                     // Even darker for search bar
    )
    
    // Cuisine categories with icons
    private let categories = [
        ("Sushi", "🍱"),
        ("Pizza", "🍕"),
        ("Halal", "🥙"),
        ("Chinese", "🥡"),
        ("Thai", "🍜"),
        ("Indian", "🍛"),
        ("Italian", "🍝"),
        ("Mexican", "🌮")
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Location and Profile Header
                    HStack {
                        // Location Button
                        Button {
                            // Handle location selection
                        } label: {
                            HStack {
                                if let address = locationManager.address {
                                    Text(address)
                                        .font(.headline)
                                        .foregroundColor(colors.text)
                                } else {
                                    Text("Set Location")
                                        .font(.headline)
                                        .foregroundColor(colors.text)
                                }
                                Image(systemName: "chevron.down")
                                    .foregroundColor(colors.primary)
                            }
                        }
                        
                        Spacer()
                        
                        // Profile Button
                        Button {
                            // Handle profile
                        } label: {
                            Image(systemName: "person.circle.fill")
                                .font(.title2)
                                .foregroundColor(colors.primary)
                        }
                    }
                    .padding(.horizontal)
                    
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
                    
                    // Cuisine Categories
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(categories, id: \.0) { category in
                                VStack {
                                    Text(category.1)
                                        .font(.system(size: 30))
                                    Text(category.0)
                                        .font(.caption)
                                        .foregroundColor(colors.text)
                                }
                                .frame(width: 70, height: 70)
                                .background(colors.cardBackground)
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Featured Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Featured Restaurants")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(colors.text)
                            
                            Spacer()
                            
                            Button {
                                // Show all
                            } label: {
                                Text("See All")
                                    .foregroundColor(colors.primary)
                            }
                        }
                        .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(0..<5) { _ in
                                    FeaturedRestaurantCard(colors: colors)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Recent Orders Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Order Again")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(colors.text)
                            
                            Spacer()
                            
                            Button {
                                // Show all
                            } label: {
                                Text("See All")
                                    .foregroundColor(colors.primary)
                            }
                        }
                        .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(0..<5) { _ in
                                    RecentOrderCard(colors: colors)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .background(colors.background.ignoresSafeArea())
        }
    }
}

struct FeaturedRestaurantCard: View {
    let colors: (
        background: Color,
        primary: Color,
        secondary: Color,
        text: Color,
        cardBackground: Color,
        searchBackground: Color
    )
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Restaurant Image
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 250, height: 150)
                .cornerRadius(12)
                .overlay(
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundColor(colors.secondary)
                )
            
            // Restaurant Info
            VStack(alignment: .leading, spacing: 4) {
                Text("Restaurant Name")
                    .font(.headline)
                    .foregroundColor(colors.text)
                
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("4.5")
                        .foregroundColor(colors.text)
                    Text("(500+)")
                        .foregroundColor(colors.secondary)
                    Text("•")
                        .foregroundColor(colors.secondary)
                    Text("15-25 min")
                        .foregroundColor(colors.secondary)
                }
                .font(.caption)
            }
            .padding(.horizontal, 4)
        }
        .frame(width: 250)
        .background(colors.cardBackground)
        .cornerRadius(16)
    }
}

struct RecentOrderCard: View {
    let colors: (
        background: Color,
        primary: Color,
        secondary: Color,
        text: Color,
        cardBackground: Color,
        searchBackground: Color
    )
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Restaurant Image
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 200, height: 120)
                .cornerRadius(12)
                .overlay(
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundColor(colors.secondary)
                )
            
            // Restaurant Info
            VStack(alignment: .leading, spacing: 4) {
                Text("Restaurant Name")
                    .font(.headline)
                    .foregroundColor(colors.text)
                
                Text("20 min")
                    .font(.caption)
                    .foregroundColor(colors.secondary)
            }
            .padding(.horizontal, 4)
        }
        .frame(width: 200)
        .background(colors.cardBackground)
        .cornerRadius(16)
    }
}

#Preview {
    HomeView(preferences: UserPreferences())
        .preferredColorScheme(.dark)
} 