import CoreLocation
import SwiftUI

@MainActor
class LocationManager: NSObject, ObservableObject {
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var lastKnownAddress: String?
    @Published var error: Error?

    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 100 // meters
    }

    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }

    private func updateAddress(for location: CLLocation) {
        Task {
            do {
                let placemarks = try await geocoder.reverseGeocodeLocation(location)
                if let placemark = placemarks.first {
                    var addressComponents: [String] = []

                    if let thoroughfare = placemark.thoroughfare {
                        addressComponents.append(thoroughfare)
                    }

                    if let locality = placemark.locality {
                        addressComponents.append(locality)
                    }

                    lastKnownAddress = addressComponents.joined(separator: ", ")
                }
            } catch {
                self.error = error
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus

        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            startUpdatingLocation()
        case .denied, .restricted:
            error = LocationError.permissionDenied
            stopUpdatingLocation()
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }

    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        // Filter out old or invalid locations
        let howRecent = location.timestamp.timeIntervalSinceNow
        guard abs(howRecent) < 15,
              location.horizontalAccuracy >= 0,
              location.horizontalAccuracy < 100 else { return }

        currentLocation = location
        updateAddress(for: location)
    }

    func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        if let error = error as? CLError {
            switch error.code {
            case .denied:
                self.error = LocationError.permissionDenied
            case .locationUnknown:
                self.error = LocationError.locationUnavailable
            default:
                self.error = error
            }
        } else {
            self.error = error
        }

        stopUpdatingLocation()
    }
}

// MARK: - Location Error

enum LocationError: LocalizedError {
    case permissionDenied
    case locationUnavailable

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Location access was denied. Please enable location services in Settings to find restaurants near you."
        case .locationUnavailable:
            return "Unable to determine your location. Please try again later."
        }
    }
}
