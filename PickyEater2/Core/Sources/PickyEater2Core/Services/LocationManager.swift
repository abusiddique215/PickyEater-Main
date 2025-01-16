import Foundation
import CoreLocation

@MainActor
public final class LocationManager: NSObject, ObservableObject {
    private let manager = CLLocationManager()
    @Published public var currentLocation: CLLocation?
    @Published public var authorizationStatus: CLAuthorizationStatus
    
    public override init() {
        authorizationStatus = .notDetermined
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 10
    }
    
    public func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
    }
    
    public func startUpdatingLocation() {
        manager.startUpdatingLocation()
    }
    
    public func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    nonisolated public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            currentLocation = locations.last
        }
    }
    
    nonisolated public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
    
    nonisolated public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        Task { @MainActor in
            authorizationStatus = status
            if status == .authorized {
                startUpdatingLocation()
            }
        }
    }
} 