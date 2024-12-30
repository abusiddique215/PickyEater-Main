//
//  ContentView.swift
//  PickyEater2
//
//  Created by Abu Siddique on 12/29/24.
//

import SwiftUI
import SwiftData
import CoreLocation

@Model
class UserPreferences {
    var maxDistance: Double
    var priceRange: String
    var dietaryRestrictions: [String]
    var cuisinePreferences: [String]
    
    init(maxDistance: Double = 5.0,
         priceRange: String = "$$",
         dietaryRestrictions: [String] = [],
         cuisinePreferences: [String] = []) {
        self.maxDistance = maxDistance
        self.priceRange = priceRange
        self.dietaryRestrictions = dietaryRestrictions
        self.cuisinePreferences = cuisinePreferences
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var savedPreferences: [UserPreferences]
    @StateObject private var locationManager = LocationManager()
    @State private var showingPreferences = false
    
    var preferences: UserPreferences {
        if let existing = savedPreferences.first {
            return existing
        } else {
            let new = UserPreferences()
            modelContext.insert(new)
            return new
        }
    }
    
    var body: some View {
        Group {
            switch locationManager.authorizationStatus {
            case .notDetermined:
                ProgressView("Requesting location access...")
            case .restricted, .denied:
                ContentUnavailableView("Location Access Required",
                    systemImage: "location.slash",
                    description: Text("Please enable location access in Settings to find restaurants near you.")
                )
                .overlay(
                    Button("Open Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    .buttonStyle(.bordered)
                    .padding(.top, 20),
                    alignment: .bottom
                )
            case .authorizedWhenInUse, .authorizedAlways:
                mainView
            @unknown default:
                Text("Unknown authorization status")
            }
        }
    }
    
    private var mainView: some View {
        NavigationStack {
            RestaurantListView(
                preferences: preferences,
                location: locationManager.location,
                authorizationStatus: locationManager.authorizationStatus
            )
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingPreferences = true }) {
                        Label("Preferences", systemImage: "slider.horizontal.3")
                    }
                }
            }
            .sheet(isPresented: $showingPreferences) {
                NavigationStack {
                    PreferencesView(preferences: preferences)
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
            }
        }
    }
}

@MainActor
final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager: CLLocationManager
    private var isUpdating = false
    private var lastLocationUpdate: Date?
    private let updateThrottle: TimeInterval = 5 // Minimum seconds between updates
    
    @Published private(set) var location: CLLocation?
    @Published private(set) var authorizationStatus: CLAuthorizationStatus
    @Published private(set) var lastError: Error?
    
    override init() {
        self.manager = CLLocationManager()
        self.authorizationStatus = manager.authorizationStatus
        
        super.init()
        
        Task {
            await setupLocationManager()
        }
    }
    
    private func setupLocationManager() async {
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = 100 // meters
        manager.pausesLocationUpdatesAutomatically = true
        manager.allowsBackgroundLocationUpdates = false     
        
        await MainActor.run {
            manager.requestWhenInUseAuthorization()
        }
    }
    
    private func startUpdatingLocation() {
        guard !isUpdating else { return }
        isUpdating = true
        Task {
            await MainActor.run {
                manager.startUpdatingLocation()
                print("Started updating location")
            }
        }
    }
    
    private func stopUpdatingLocation() {
        guard isUpdating else { return }
        isUpdating = false
        Task {
            await MainActor.run {
                manager.stopUpdatingLocation()
                print("Stopped updating location")
            }
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.authorizationStatus = manager.authorizationStatus
            print("Location authorization status changed to: \(authorizationStatus.rawValue)")
            
            switch authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                self.startUpdatingLocation()
            case .denied, .restricted:
                self.stopUpdatingLocation()
                self.lastError = NSError(
                    domain: "LocationManager",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Location access denied"]
                )
            default:
                break
            }
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last,
              newLocation.horizontalAccuracy >= 0 else { return }
        
        Task { @MainActor in
            // Only update if significant change or first location
            if let currentLocation = self.location {
                let distance = newLocation.distance(from: currentLocation)
                if distance < 100 { // Less than 100 meters change
                    return
                }
            }
            
            self.location = newLocation
            self.lastLocationUpdate = Date()
            print("Location updated: \(newLocation.coordinate.latitude), \(newLocation.coordinate.longitude)")
            
            // Stop updates after getting a good location
            self.stopUpdatingLocation()
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            print("Location error: \(error.localizedDescription)")
            self.lastError = error
            
            if let clError = error as? CLError {
                switch clError.code {
                case .denied:
                    self.authorizationStatus = .denied
                    self.stopUpdatingLocation()
                case .locationUnknown:
                    // Only retry once
                    if self.isUpdating {
                        self.stopUpdatingLocation()
                    }
                default:
                    print("CLError: \(clError.code)")
                    self.stopUpdatingLocation()
                }
            } else {
                self.stopUpdatingLocation()
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: UserPreferences.self, inMemory: true)
}
