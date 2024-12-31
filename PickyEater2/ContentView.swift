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
    @Query(sort: \UserPreferences.maxDistance) private var preferences: [UserPreferences]
    @StateObject private var locationManager = LocationManager()
    @State private var showingPreferences = false
    
    private var currentPreferences: UserPreferences {
        if let existing = preferences.first {
            return existing
        }
        
        // Create new preferences
        let new = UserPreferences()
        modelContext.insert(new)
        do {
            try modelContext.save()
            print("Created new preferences with id: \(new.id)")
        } catch {
            print("Failed to save preferences: \(error)")
        }
        return new
    }
    
    var body: some View {
        Group {
            switch locationManager.state {
            case .notDetermined, .unavailable:
                ContentUnavailableView {
                    Label("Requesting Location Access", systemImage: locationManager.state.systemImage)
                } description: {
                    Text(locationManager.state.description)
                }
            case .restricted, .denied:
                ContentUnavailableView {
                    Label("Location Access Required", systemImage: locationManager.state.systemImage)
                } description: {
                    Text(locationManager.state.description)
                } actions: {
                    Button("Open Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    .buttonStyle(.bordered)
                }
            case .authorized:
                mainView
            }
        }
        .animation(.default, value: locationManager.state)
    }
    
    @ViewBuilder
    private var mainView: some View {
        NavigationStack {
            if locationManager.location != nil {
                RestaurantListView(preferences: currentPreferences)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showingPreferences = true
                        } label: {
                            Label("Preferences", systemImage: "slider.horizontal.3")
                        }
                    }
                }
                .sheet(isPresented: $showingPreferences) {
                    NavigationStack {
                        PreferencesView(preferences: currentPreferences)
                            .navigationTitle("Preferences")
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .confirmationAction) {
                                    Button("Done") {
                                        showingPreferences = false
                                    }
                                }
                            }
                    }
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
                }
            } else {
                ContentUnavailableView {
                    Label("Waiting for Location", systemImage: "location.circle")
                } description: {
                    Text("Please wait while we get your location...")
                }
            }
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: UserPreferences.self, configurations: config)
        let context = container.mainContext
        let preferences = UserPreferences()
        context.insert(preferences)
        try context.save()
        
        return ContentView()
            .modelContainer(container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
