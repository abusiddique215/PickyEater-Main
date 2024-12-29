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
    @StateObject private var locationManager = LocationManager()
    @State private var selectedTab = 0
    
    var userPreferences: UserPreferences {
        if let existing = preferences.first {
            return existing
        } else {
            let new = UserPreferences()
            modelContext.insert(new)
            return new
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            RestaurantListView(
                preferences: userPreferences,
                location: locationManager.location
            )
            .tabItem {
                Label("Restaurants", systemImage: "fork.knife")
            }
            .tag(0)
            
            PreferencesView(preferences: userPreferences)
                .tabItem {
                    Label("Preferences", systemImage: "slider.horizontal.3")
                }
                .tag(1)
        }
        .onAppear {
            locationManager.requestLocation()
        }
    }
}

// MARK: - Location Manager
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var location: CLLocation?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}

#Preview {
    ContentView()
        .modelContainer(for: UserPreferences.self, inMemory: true)
}
