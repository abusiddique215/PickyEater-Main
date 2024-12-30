import SwiftUI
import SwiftData

struct MainTabView: View {
    @State private var selectedTab = 0
    @Environment(\.modelContext) private var modelContext
    @Query private var preferences: [UserPreferences]
    
    private var currentPreferences: UserPreferences {
        if let existing = preferences.first {
            return existing
        }
        let new = UserPreferences()
        modelContext.insert(new)
        try? modelContext.save()
        return new
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                CuisineSelectionView(preferences: .constant(currentPreferences))
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)
            
            NavigationStack {
                FavoritesView()
            }
            .tabItem {
                Label("My List", systemImage: "bookmark.fill")
            }
            .tag(1)
            
            NavigationStack {
                Text("Coming Soon!")
                    .font(.title)
                    .foregroundColor(.secondary)
            }
            .tabItem {
                Label("Vote", systemImage: "chart.bar.fill")
            }
            .tag(2)
            
            NavigationStack {
                Text("Coming Soon!")
                    .font(.title)
                    .foregroundColor(.secondary)
            }
            .tabItem {
                Label("Results", systemImage: "list.bullet")
            }
            .tag(3)
        }
        .tint(.pink)
        .preferredColorScheme(.dark)
    }
}

struct FavoritesView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("My Restaurants")
                    .font(.system(size: 40, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                ForEach(0..<5) { _ in
                    RestaurantCard()
                }
            }
            .padding(.vertical)
        }
        .background(Color.black)
    }
}

struct RestaurantCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("L'Estaminet")
                    .font(.title2)
                    .bold()
                Spacer()
                Button {
                    // Share action
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.white)
                }
            }
            
            HStack {
                Image(systemName: "location.fill")
                Text("Location: Ahuntsic-Cartierville")
            }
            .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: "fork.knife")
                Text("Cuisine: Bistro, French, Comfort Food, Regional, Market, Breakfast")
            }
            .foregroundColor(.secondary)
            
            // Placeholder for restaurant image
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Text("Tap to see more options")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding()
        .background(Color.black)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

#Preview {
    MainTabView()
} 