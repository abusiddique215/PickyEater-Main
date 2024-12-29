import SwiftUI
import SwiftData
import Observation

struct PreferencesView: View {
    @Bindable var preferences: UserPreferences
    
    let dietaryOptions = [
        "Vegetarian", "Vegan", "Gluten-Free",
        "Halal", "Kosher", "Dairy-Free"
    ]
    
    let cuisineOptions = [
        "American", "Chinese", "Italian",
        "Japanese", "Mexican", "Indian",
        "Thai", "Mediterranean", "Korean"
    ]
    
    let priceRanges = ["$", "$$", "$$$", "$$$$"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Dietary Restrictions")) {
                    ForEach(dietaryOptions, id: \.self) { option in
                        Toggle(option, isOn: Binding(
                            get: { preferences.dietaryRestrictions.contains(option) },
                            set: { isSelected in
                                if isSelected {
                                    preferences.dietaryRestrictions.append(option)
                                } else {
                                    preferences.dietaryRestrictions.removeAll { $0 == option }
                                }
                            }
                        ))
                    }
                }
                
                Section(header: Text("Cuisine Preferences")) {
                    ForEach(cuisineOptions, id: \.self) { cuisine in
                        Toggle(cuisine, isOn: Binding(
                            get: { preferences.cuisinePreferences.contains(cuisine) },
                            set: { isSelected in
                                if isSelected {
                                    preferences.cuisinePreferences.append(cuisine)
                                } else {
                                    preferences.cuisinePreferences.removeAll { $0 == cuisine }
                                }
                            }
                        ))
                    }
                }
                
                Section(header: Text("Price Range")) {
                    Picker("Price Range", selection: $preferences.priceRange) {
                        ForEach(priceRanges, id: \.self) { price in
                            Text(price).tag(price)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section(header: Text("Maximum Distance")) {
                    Slider(
                        value: $preferences.maxDistance,
                        in: 1...20,
                        step: 0.5
                    ) {
                        Text("Maximum Distance")
                    } minimumValueLabel: {
                        Text("1mi")
                    } maximumValueLabel: {
                        Text("20mi")
                    }
                    Text("\(preferences.maxDistance, specifier: "%.1f") miles")
                }
            }
            .navigationTitle("Preferences")
        }
    }
}

#Preview {
    PreferencesView(preferences: UserPreferences())
        .modelContainer(for: UserPreferences.self, inMemory: true)
} 