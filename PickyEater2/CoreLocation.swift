import Foundation
import CoreLocation
import SwiftUI

@MainActor
final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus
    private var isUpdatingLocation = false
    
    override init() {
        authorizationStatus = manager.authorizationStatus
        super.init()
        
        Task {
            await setupLocationManager()
        }
    }
    
    private func setupLocationManager() async {
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = 100 // Update location when user moves 100 meters
        manager.pausesLocationUpdatesAutomatically = true
        manager.allowsBackgroundLocationUpdates = false
        
        // Request authorization on a background queue
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                self.manager.requestWhenInUseAuthorization()
                continuation.resume()
            }
        }
    }
    
    private func startUpdatingLocation() {
        guard !isUpdatingLocation else { return }
        isUpdatingLocation = true
        DispatchQueue.global(qos: .userInitiated).async {
            self.manager.startUpdatingLocation()
        }
    }
    
    private func stopUpdatingLocation() {
        guard isUpdatingLocation else { return }
        isUpdatingLocation = false
        DispatchQueue.global(qos: .userInitiated).async {
            self.manager.stopUpdatingLocation()
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            let newStatus = manager.authorizationStatus
            self.authorizationStatus = newStatus
            
            switch newStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                self.startUpdatingLocation()
            case .denied, .restricted:
                self.stopUpdatingLocation()
                self.location = nil
            case .notDetermined:
                break
            @unknown default:
                break
            }
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        Task { @MainActor in
            self.location = location
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                Task { @MainActor in
                    self.stopUpdatingLocation()
                    self.location = nil
                }
            default:
                print("Location manager failed with error: \(clError.localizedDescription)")
            }
        } else {
            print("Location manager failed with error: \(error.localizedDescription)")
        }
    }
} 