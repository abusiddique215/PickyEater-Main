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
                location: locationManager.location,
                authorizationStatus: locationManager.authorizationStatus
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
        .onChange(of: selectedTab) { oldTab, newTab in
            // Only request location when switching to restaurant tab
            if newTab == 0 && oldTab == 1 {
                locationManager.requestLocation()
            }
        }
    }
}

// MARK: - Location Manager
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var isUpdating = false
    private var lastLocationUpdate: Date?
    private let updateThrottle: TimeInterval = 5 // Minimum seconds between updates
    
    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var lastError: Error?
    
    override init() {
        authorizationStatus = .notDetermined
        super.init()
        
        // Configure location manager
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = 100 // meters
        manager.pausesLocationUpdatesAutomatically = true
        manager.allowsBackgroundLocationUpdates = false
    }
    
    func requestLocation() {
        // Don't request if we recently updated
        if let lastUpdate = lastLocationUpdate {
            let timeSinceLastUpdate = Date().timeIntervalSince(lastUpdate)
            if timeSinceLastUpdate < updateThrottle {
                print("Location update throttled. Time since last update: \(timeSinceLastUpdate)s")
                return
            }
        }
        
        lastError = nil
        
        // Check if location services are enabled
        guard CLLocationManager.locationServicesEnabled() else {
            lastError = NSError(
                domain: "LocationManager",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Location services are disabled"]
            )
            return
        }
        
        // Request authorization if not determined
        if authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
            return
        }
        
        // Start updating if authorized and not already updating
        if (authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways) && !isUpdating {
            isUpdating = true
            manager.startUpdatingLocation()
            print("Started updating location")
        }
    }
    
    func stopUpdatingLocation() {
        isUpdating = false
        manager.stopUpdatingLocation()
        print("Stopped updating location")
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        print("Location authorization status changed to: \(authorizationStatus.rawValue)")
        
        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            // Don't automatically request location, let the UI handle it
            break
        case .denied, .restricted:
            stopUpdatingLocation()
            lastError = NSError(
                domain: "LocationManager",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Location access denied"]
            )
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        
        // Filter out invalid locations
        guard newLocation.horizontalAccuracy >= 0 else { return }
        
        // Only update if significant change or first location
        if let currentLocation = location {
            let distance = newLocation.distance(from: currentLocation)
            if distance < 100 { // Less than 100 meters change
                return
            }
        }
        
        location = newLocation
        lastLocationUpdate = Date()
        print("Location updated: \(newLocation.coordinate.latitude), \(newLocation.coordinate.longitude)")
        
        // Stop updates after getting a good location
        stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
        lastError = error
        
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                authorizationStatus = .denied
                stopUpdatingLocation()
            case .locationUnknown:
                // Only retry once
                if isUpdating {
                    stopUpdatingLocation()
                }
            default:
                print("CLError: \(clError.code)")
                stopUpdatingLocation()
            }
        } else {
            stopUpdatingLocation()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: UserPreferences.self, inMemory: true)
}
