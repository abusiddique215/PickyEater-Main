import CoreLocation
import SwiftUI

enum LocationState: Equatable {
    case notDetermined
    case restricted
    case denied
    case authorized
    case unavailable
    
    var systemImage: String {
        switch self {
        case .notDetermined: "location.slash"
        case .restricted: "lock.shield"
        case .denied: "location.slash.fill"
        case .authorized: "location.fill"
        case .unavailable: "exclamationmark.triangle"
        }
    }
    
    var description: String {
        switch self {
        case .notDetermined:
            "Please allow location access to find restaurants near you"
        case .restricted:
            "Location access is restricted. Please check your device settings."
        case .denied:
            "Location access was denied. Please enable it in Settings to use this feature."
        case .authorized:
            "Location access granted"
        case .unavailable:
            "Location services are currently unavailable"
        }
    }
}

@MainActor
class LocationManager: NSObject, ObservableObject {
    @Published var location: CLLocation?
    @Published var state: LocationState = .notDetermined
    
    private let manager: CLLocationManager
    
    override init() {
        self.manager = CLLocationManager()
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        Task {
            await checkLocationAuthorization()
        }
    }
    
    private func checkLocationAuthorization() {
        switch manager.authorizationStatus {
        case .notDetermined:
            state = .notDetermined
            manager.requestWhenInUseAuthorization()
        case .restricted:
            state = .restricted
        case .denied:
            state = .denied
        case .authorizedAlways, .authorizedWhenInUse:
            state = .authorized
            manager.startUpdatingLocation()
        @unknown default:
            state = .unavailable
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            checkLocationAuthorization()
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            self.location = location
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            print("Location manager failed with error: \(error.localizedDescription)")
            state = .unavailable
        }
    }
} 