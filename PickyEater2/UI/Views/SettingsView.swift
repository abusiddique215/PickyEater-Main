import SwiftUI
import SwiftData
import PickyEater2Core

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var preferences: [UserPreferences]
    @State private var selectedTheme: AppTheme = .system
    @State private var currentPreferences: UserPreferences = UserPreferences()
    
    private var cuisinePreferencesLink: some View {
        NavigationLink {
            CuisineSelectionView(preferences: $currentPreferences)
        } label: {
            HStack {
                Text("Cuisine Preferences")
                Spacer()
                Text("\(currentPreferences.favoriteCuisines.count) selected")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Theme", selection: $selectedTheme) {
                        Text("Light").tag(AppTheme.light)
                        Text("Dark").tag(AppTheme.dark)
                        Text("System").tag(AppTheme.system)
                    }
                    .onChange(of: selectedTheme) { _, newValue in
                        if let window = UIApplication.shared.windows.first {
                            window.overrideUserInterfaceStyle = newValue.colorScheme ?? .unspecified
                        }
                    }
                } header: {
                    Text("Appearance")
                }
                
                Section {
                    cuisinePreferencesLink
                    
                    NavigationLink {
                        DietaryRestrictionsView(preferences: $currentPreferences)
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
                    Toggle("Notifications", isOn: .constant(true))
                        .tint(.accentColor)
                    
                    NavigationLink {
                        NotificationSettingsView()
                    } label: {
                        Text("Notification Settings")
                    }
                } header: {
                    Text("Notifications")
                }
                
                Section {
                    Button(role: .destructive) {
                        // Handle sign out
                    } label: {
                        Text("Sign Out")
                    }
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                loadPreferences()
            }
        }
    }
    
    private func loadPreferences() {
        if let existing = preferences.first {
            currentPreferences = existing
        } else {
            let new = UserPreferences()
            modelContext.insert(new)
            try? modelContext.save()
            currentPreferences = new
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: UserPreferences.self, inMemory: true)
}
