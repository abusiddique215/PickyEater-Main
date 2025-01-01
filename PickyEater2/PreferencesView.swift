import SwiftUI
import SwiftData
import Observation

struct PreferencesView: View {
    @Bindable var preferences: UserPreferences
    
    var body: some View {
        NavigationView {
            Form {
                dietaryRestrictionsSection
                cuisinePreferencesSection
                priceRangeSection
                distanceSection
            }
            .navigationTitle("Preferences")
        }
    }
    
    private var dietaryRestrictionsSection: some View {
        Section(header: Text("Dietary Restrictions")) {
            ForEach(DietaryOptions.allCases, id: \.self) { option in
                DietaryToggleRow(
                    option: option,
                    isSelected: preferences.dietaryRestrictions.contains(option.rawValue),
                    onToggle: { isSelected in
                        if isSelected {
                            preferences.dietaryRestrictions.append(option.rawValue)
                        } else {
                            preferences.dietaryRestrictions.removeAll { $0 == option.rawValue }
                        }
                    }
                )
            }
        }
    }
    
    private var cuisinePreferencesSection: some View {
        Section(header: Text("Cuisine Preferences")) {
            ForEach(CuisineOptions.allCases, id: \.self) { cuisine in
                CuisineToggleRow(
                    cuisine: cuisine,
                    isSelected: preferences.cuisinePreferences.contains(cuisine.rawValue),
                    onToggle: { isSelected in
                        if isSelected {
                            preferences.cuisinePreferences.append(cuisine.rawValue)
                        } else {
                            preferences.cuisinePreferences.removeAll { $0 == cuisine.rawValue }
                        }
                    }
                )
            }
        }
    }
    
    private var priceRangeSection: some View {
        Section(header: Text("Price Range")) {
            Picker("Price Range", selection: $preferences.priceRange) {
                ForEach(PriceRange.allCases, id: \.self) { price in
                    Text(price.displayText).tag(price.rawValue)
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    private var distanceSection: some View {
        Section(header: Text("Maximum Distance")) {
            VStack {
                Slider(
                    value: .init(
                        get: { Double(preferences.maxDistance) },
                        set: { preferences.maxDistance = Int($0) }
                    ),
                    in: 1...20,
                    step: 1
                ) {
                    Text("Maximum Distance")
                } minimumValueLabel: {
                    Text("1km")
                } maximumValueLabel: {
                    Text("20km")
                }
                Text("\(preferences.maxDistance) kilometers")
            }
        }
    }
}

// MARK: - Supporting Views
struct DietaryToggleRow: View {
    let option: DietaryOptions
    let isSelected: Bool
    let onToggle: (Bool) -> Void
    
    var body: some View {
        Toggle(option.rawValue, isOn: Binding(
            get: { isSelected },
            set: onToggle
        ))
    }
}

struct CuisineToggleRow: View {
    let cuisine: CuisineOptions
    let isSelected: Bool
    let onToggle: (Bool) -> Void
    
    var body: some View {
        Toggle(cuisine.rawValue, isOn: Binding(
            get: { isSelected },
            set: onToggle
        ))
    }
}

// MARK: - Enums
enum DietaryOptions: String, CaseIterable {
    case vegetarian = "Vegetarian"
    case vegan = "Vegan"
    case glutenFree = "Gluten-Free"
    case halal = "Halal"
    case kosher = "Kosher"
    case dairyFree = "Dairy-Free"
}

enum CuisineOptions: String, CaseIterable {
    case american = "American"
    case chinese = "Chinese"
    case italian = "Italian"
    case japanese = "Japanese"
    case mexican = "Mexican"
    case indian = "Indian"
    case thai = "Thai"
    case mediterranean = "Mediterranean"
    case korean = "Korean"
}

enum PriceRange: Int, CaseIterable {
    case low = 1
    case medium = 2
    case high = 3
    case veryHigh = 4
    
    var displayText: String {
        String(repeating: "$", count: rawValue)
    }
}

#Preview {
    PreferencesView(preferences: UserPreferences())
        .modelContainer(for: UserPreferences.self, inMemory: true)
} 