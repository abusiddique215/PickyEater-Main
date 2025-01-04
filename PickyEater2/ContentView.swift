//
//  ContentView.swift
//  PickyEater2
//
//  Created by Abu Siddique on 12/29/24.
//

import SwiftUI
import SwiftData
import CoreLocation

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var preferences: [UserPreferences]
    @State private var showingPreferences = false
    
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
        NavigationStack {
            RestaurantListView(preferences: currentPreferences)
                .sheet(isPresented: $showingPreferences) {
                    PreferencesView(preferences: Binding(
                        get: { currentPreferences },
                        set: { newValue in
                            if let existing = preferences.first {
                                existing.dietaryRestrictions = newValue.dietaryRestrictions
                                existing.cuisinePreferences = newValue.cuisinePreferences
                                existing.maxDistance = newValue.maxDistance
                                existing.priceRange = newValue.priceRange
                                try? modelContext.save()
                            }
                        }
                    ))
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showingPreferences.toggle()
                        } label: {
                            Image(systemName: "slider.horizontal.3")
                        }
                    }
                }
        }
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
    ContentView()
        .modelContainer(for: UserPreferences.self, inMemory: true)
}
