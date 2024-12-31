import CoreLocation
import SwiftUI

enum LocationState: Equatable {
    case notDetermined
    case restricted
    case denied
    case authorized
    case unavailable
    
    var description: String {
        switch self {
        case .notDetermined:
            "Please allow location access to find restaurants near you"
        case .restricted, .denied:
            "Location access is required to find restaurants near you. Please enable it in Settings."
        case .authorized:
            "Finding your location..."
        case .unavailable:
            "Location services are unavailable"
        }
    }
    
    var systemImage: String {
        switch self {
        case .notDetermined, .authorized:
            "location.circle"
        case .restricted, .denied:
            "location.slash.circle"
        case .unavailable:
            "exclamationmark.triangle"
        }
    }
}

@MainActor
final class LocationManager: NSObject, ObservableObject {
    private let manager: CLLocationManager
    
    @Published private(set) var location: CLLocation?
    @Published private(set) var state: LocationState = .notDetermined
    @Published private(set) var lastError: Error?
    
    override init() {
        self.manager = CLLocationManager()
        super.init()
        
        self.manager.delegate = self
        self.manager.desiredAccuracy = kCLLocationAccuracyBest
        self.manager.distanceFilter = kCLDistanceFilterNone
        self.manager.pausesLocationUpdatesAutomatically = false
        
        Task {
            await requestLocationPermission()
        }
    }
    
    private func requestLocationPermission() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            state = .denied
        case .authorizedWhenInUse, .authorizedAlways:
            state = .authorized
            manager.startUpdatingLocation()
        @unknown default:
            state = .unavailable
        }
    }
    
    func startUpdatingLocation() {
        manager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            switch manager.authorizationStatus {
            case .notDetermined:
                state = .notDetermined
            case .restricted:
                state = .restricted
            case .denied:
                state = .denied
            case .authorizedWhenInUse, .authorizedAlways:
                state = .authorized
                manager.startUpdatingLocation()
            @unknown default:
                state = .unavailable
            }
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        Task { @MainActor in
            // Only update if accuracy is good enough
            if location.horizontalAccuracy <= 100 {
                self.location = location
                self.lastError = nil
            }
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.lastError = error
            if let error = error as? CLError {
                switch error.code {
                case .denied:
                    state = .denied
                case .locationUnknown:
                    state = .unavailable
                default:
                    print("Location manager failed with error: \(error.localizedDescription)")
                }
            }
        }
    }
} 