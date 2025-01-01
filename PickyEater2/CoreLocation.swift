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
    
    private let manager = CLLocationManager()
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        Task {
            await requestLocationPermission()
        }
    }
    
    private func requestLocationPermission() async {
        switch manager.authorizationStatus {
        case .notDetermined:
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
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            await requestLocationPermission()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
        state = .unavailable
    }
} 