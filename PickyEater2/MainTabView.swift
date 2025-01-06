import SwiftUI
import SwiftData

struct MainTabView: View {
    @StateObject private var themeManager = ThemeManager.shared
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
                HomeView(preferences: currentPreferences)
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)
            
            NavigationStack {
                SearchView()
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }
            .tag(1)
            
            NavigationStack {
                Text("Map")
                    .navigationTitle("Map")
            }
            .tabItem {
                Label("Map", systemImage: "map")
            }
            .tag(2)
            
            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
            .tag(3)
        }
        .withTheme()
        .modelContainer(for: UserPreferences.self)
        .task {
            if preferences.isEmpty {
                let new = UserPreferences()
                modelContext.insert(new)
                try? modelContext.save()
            }
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: UserPreferences.self, inMemory: true)
} 