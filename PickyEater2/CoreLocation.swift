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
    private var authorizationContinuation: CheckedContinuation<Void, Never>?
    
    @Published private(set) var location: CLLocation?
    @Published private(set) var state: LocationState = .notDetermined
    
    override init() {
        self.manager = CLLocationManager()
        super.init()
        
        self.manager.delegate = self
        self.manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        self.manager.distanceFilter = 100
        
        Task {
            await requestLocationPermission()
        }
    }
    
    private func requestLocationPermission() async {
        let status = manager.authorizationStatus
        
        switch status {
        case .notDetermined:
            await withCheckedContinuation { continuation in
                authorizationContinuation = continuation
                manager.requestWhenInUseAuthorization()
            }
            await updateAuthorizationState()
            
        case .restricted, .denied:
            await updateAuthorizationState()
            
        case .authorizedWhenInUse, .authorizedAlways:
            await updateAuthorizationState()
            manager.startUpdatingLocation()
            
        @unknown default:
            state = .unavailable
        }
    }
    
    private func updateAuthorizationState() async {
        switch manager.authorizationStatus {
        case .notDetermined:
            state = .notDetermined
        case .restricted:
            state = .restricted
        case .denied:
            state = .denied
        case .authorizedAlways, .authorizedWhenInUse:
            state = .authorized
        @unknown default:
            state = .unavailable
        }
    }
    
    @MainActor
    private func updateLocation(_ location: CLLocation) {
        self.location = location
    }
    
    @MainActor
    private func handleLocationError(_ error: CLError) {
        switch error.code {
        case .denied:
            state = .denied
        case .locationUnknown:
            state = .unavailable
        default:
            break
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            await updateAuthorizationState()
            if manager.authorizationStatus == .authorizedWhenInUse || 
               manager.authorizationStatus == .authorizedAlways {
                manager.startUpdatingLocation()
            }
            authorizationContinuation?.resume()
            authorizationContinuation = nil
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            await updateLocation(location)
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
        if let error = error as? CLError {
            Task { @MainActor in
                await handleLocationError(error)
            }
        }
    }
} 