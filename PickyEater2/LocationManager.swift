import CoreLocation
import SwiftUI

class LocationManager: NSObject, ObservableObject {
    private let manager = CLLocationManager()
    @Published var location: CLLocation?
    @Published var address: String?
    @Published var state: LocationState = .notDetermined
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        checkAuthorizationStatus()
    }
    
    private func checkAuthorizationStatus() {
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
    
    private func updateAddress(from location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                self.address = "Location unavailable"
                return
            }
            
            if let placemark = placemarks?.first {
                let addressComponents = [
                    placemark.subThoroughfare,
                    placemark.thoroughfare,
                    placemark.locality
                ].compactMap { $0 }
                
                if !addressComponents.isEmpty {
                    self.address = addressComponents.joined(separator: " ")
                } else {
                    self.address = "Location unavailable"
                }
            }
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.checkAuthorizationStatus()
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            self.location = location
            self.updateAddress(from: location)
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            print("Location error: \(error.localizedDescription)")
            self.state = .unavailable
        }
    }
}

enum LocationState {
    case notDetermined
    case restricted
    case denied
    case authorized
    case unavailable
    
    var description: String {
        switch self {
        case .notDetermined:
            return "Please allow location access to find restaurants near you."
        case .restricted:
            return "Location access is restricted. Please check your device settings."
        case .denied:
            return "Location access was denied. Please enable it in Settings to find restaurants near you."
        case .authorized:
            return "Finding your location..."
        case .unavailable:
            return "Location services are unavailable."
        }
    }
    
    var systemImage: String {
        switch self {
        case .notDetermined, .authorized:
            return "location"
        case .restricted, .denied:
            return "location.slash"
        case .unavailable:
            return "exclamationmark.triangle"
        }
    }
} 