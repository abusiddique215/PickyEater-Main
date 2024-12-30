import Foundation
import CoreLocation
import SwiftUI

/// A class that manages location services for the app
@MainActor
final class LocationManager: NSObject, ObservableObject {
    // MARK: - Properties
    nonisolated let manager = CLLocationManager()
    private var isUpdating = false
    private var lastLocationUpdate: Date?
    private let updateThrottle: TimeInterval = 5 // Minimum seconds between updates
    
    @Published private(set) var location: CLLocation?
    @Published private(set) var authorizationStatus: CLAuthorizationStatus
    @Published private(set) var lastError: Error?
    @Published private(set) var state: LocationState = .notDetermined
    
    /// The current state of location services
    enum LocationState {
        case unavailable
        case restricted
        case denied
        case notDetermined
        case authorized
        
        var systemImage: String {
            switch self {
            case .unavailable, .restricted, .denied:
                return "location.slash.circle"
            case .notDetermined:
                return "location.circle"
            case .authorized:
                return "location.circle.fill"
            }
        }
        
        var description: String {
            switch self {
            case .unavailable:
                return "Location services are not available on this device"
            case .restricted:
                return "Location access has been restricted"
            case .denied:
                return "Please enable location access in Settings to find restaurants near you"
            case .notDetermined:
                return "Location access is required to find restaurants near you"
            case .authorized:
                return "Location access granted"
            }
        }
    }
    
    // MARK: - Initialization
    override init() {
        self.authorizationStatus = manager.authorizationStatus
        super.init()
        
        manager.delegate = self
        setupLocationManager()
        updateLocationState()
    }
    
    // MARK: - Private Methods
    private func setupLocationManager() {
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = 100 // meters
        manager.pausesLocationUpdatesAutomatically = true
        manager.allowsBackgroundLocationUpdates = false
        manager.showsBackgroundLocationIndicator = true
        manager.requestWhenInUseAuthorization()
    }
    
    private func updateLocationState() {
        let newState: LocationState
        
        if !CLLocationManager.locationServicesEnabled() {
            newState = .unavailable
        } else {
            switch authorizationStatus {
            case .notDetermined:
                newState = .notDetermined
            case .restricted:
                newState = .restricted
            case .denied:
                newState = .denied
            case .authorizedWhenInUse, .authorizedAlways:
                newState = .authorized
            @unknown default:
                newState = .notDetermined
            }
        }
        
        state = newState
    }
    
    nonisolated private func startUpdatingLocation() {
        Task { @MainActor in
            guard !isUpdating else { return }
            isUpdating = true
            manager.startUpdatingLocation()
            print("Started updating location")
        }
    }
    
    nonisolated private func stopUpdatingLocation() {
        Task { @MainActor in
            guard isUpdating else { return }
            isUpdating = false
            manager.stopUpdatingLocation()
            print("Stopped updating location")
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            self.authorizationStatus = status
            updateLocationState()
            print("Location authorization status changed to: \(status.rawValue)")
            
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                startUpdatingLocation()
            case .denied, .restricted:
                stopUpdatingLocation()
                self.lastError = NSError(
                    domain: "LocationManager",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: state.description]
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
            if let currentLocation = location {
                let distance = newLocation.distance(from: currentLocation)
                if distance < 100 { return }
            }
            
            self.location = newLocation
            self.lastLocationUpdate = Date()
            print("Location updated: \(newLocation.coordinate.latitude), \(newLocation.coordinate.longitude)")
            stopUpdatingLocation()
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
                    updateLocationState()
                    stopUpdatingLocation()
                case .locationUnknown:
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
} 