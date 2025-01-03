import SwiftUI
import SwiftData

struct MainTabView: View {
    @State private var selectedTab = 0
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \UserPreferences.maxDistance) private var preferences: [UserPreferences]
    @State private var currentTheme: AppTheme = .system
    
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
                ContentView()
            }
            .tag(0)
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            
            NavigationStack {
                LocationSelectionView(preferences: .constant(currentPreferences))
            }
            .tag(1)
            .tabItem {
                Label("Explore", systemImage: "location.fill")
            }
            
            NavigationStack {
                Text("Stats Coming Soon")
                    .navigationTitle("Stats")
            }
            .tag(2)
            .tabItem {
                Label("Stats", systemImage: "chart.bar.fill")
            }
            
            NavigationStack {
                SettingsView()
            }
            .tag(3)
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
        }
        .modifier(ThemeModifier(theme: currentTheme))
        .onChange(of: currentPreferences.theme) { _, newTheme in
            withAnimation {
                currentTheme = newTheme
            }
        }
        .task {
            // Ensure preferences exist and set initial theme
            if preferences.isEmpty {
                let new = UserPreferences()
                modelContext.insert(new)
                try? modelContext.save()
            }
            currentTheme = currentPreferences.theme
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: UserPreferences.self, configurations: config)
        return MainTabView()
            .modelContainer(container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
} 