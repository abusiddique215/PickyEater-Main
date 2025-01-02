import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \UserPreferences.maxDistance) private var preferences: [UserPreferences]
    @State private var selectedTheme: AppTheme = .system
    @State private var currentPreferences: UserPreferences = UserPreferences()
    
    private var cuisinePreferencesLink: some View {
        NavigationLink {
            CuisineSelectionView(preferences: $currentPreferences)
        } label: {
            HStack {
                Text("Cuisine Preferences")
                Spacer()
                Text("\(currentPreferences.cuisinePreferences.count) selected")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Theme", selection: $selectedTheme) {
                        Text("Light").tag(AppTheme.light)
                        Text("Dark").tag(AppTheme.dark)
                        Text("System").tag(AppTheme.system)
                    }
                    .onChange(of: selectedTheme) { _, newValue in
                        currentPreferences.theme = newValue
                        try? modelContext.save()
                    }
                } header: {
                    Text("Appearance")
                }
                
                Section {
                    cuisinePreferencesLink
                    
                    NavigationLink {
                        Text("Dietary Restrictions Coming Soon")
                    } label: {
                        HStack {
                            Text("Dietary Restrictions")
                            Spacer()
                            Text("\(currentPreferences.dietaryRestrictions.count) selected")
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("Food Preferences")
                }
                
                Section {
                    HStack {
                        Text("Maximum Distance")
                        Spacer()
                        Text("\(currentPreferences.maxDistance) km")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Price Range")
                        Spacer()
                        Text(String(repeating: "$", count: currentPreferences.priceRange))
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Search Settings")
                }
                
                Section {
                    Button(role: .destructive) {
                        // Reset preferences
                        let new = UserPreferences()
                        modelContext.insert(new)
                        if let existing = preferences.first {
                            modelContext.delete(existing)
                        }
                        try? modelContext.save()
                        currentPreferences = new
                        selectedTheme = new.theme
                    } label: {
                        Text("Reset All Settings")
                    }
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                if let existing = preferences.first {
                    currentPreferences = existing
                } else {
                    let new = UserPreferences()
                    modelContext.insert(new)
                    try? modelContext.save()
                    currentPreferences = new
                }
                selectedTheme = currentPreferences.theme
            }
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: UserPreferences.self, inMemory: true)
} 