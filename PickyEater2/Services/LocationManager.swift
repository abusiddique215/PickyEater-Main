import Combine
import CoreLocation
import Foundation

@MainActor
class LocationManager: NSObject, ObservableObject {
    @Published private(set) var location: CLLocation?
    @Published private(set) var authorizationStatus: CLAuthorizationStatus
    @Published private(set) var error: LocationError?

    private let locationManager: CLLocationManager
    private let cache: LocationCache
    private var updateTimer: Timer?
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    // Configuration
    private let significantDistanceChange: CLLocationDistance = 100 // meters
    private let locationTimeout: TimeInterval = 15
    private let cacheValidityDuration: TimeInterval = 300 // 5 minutes
    private let lowBatteryAccuracy: CLLocationAccuracy = kCLLocationAccuracyHundredMeters
    private let normalAccuracy: CLLocationAccuracy = kCLLocationAccuracyNearestTenMeters

    enum LocationError: LocalizedError {
        case denied
        case restricted
        case timeout
        case unavailable
        case precisionReduced
        case unknown(Error)

        var errorDescription: String? {
            switch self {
            case .denied:
                return "Location access denied. Please enable location services in Settings."
            case .restricted:
                return "Location access restricted. Please check your device settings."
            case .timeout:
                return "Location request timed out. Please try again."
            case .unavailable:
                return "Location services are currently unavailable."
            case .precisionReduced:
                return "Location precision is reduced. Some features may be limited."
            case let .unknown(error):
                return "Location error: \(error.localizedDescription)"
            }
        }
    }

    override init() {
        locationManager = CLLocationManager()
        authorizationStatus = locationManager.authorizationStatus
        cache = LocationCache()

        super.init()

        setupLocationManager()
        loadCachedLocation()
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.activityType = .other
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.allowsBackgroundLocationUpdates = false

        // Adjust accuracy based on battery state
        updateAccuracyForBatteryState()

        // Listen for battery state changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(batteryStateDidChange),
            name: UIDevice.batteryStateDidChangeNotification,
            object: nil
        )
        UIDevice.current.isBatteryMonitoringEnabled = true
    }

    @objc private func batteryStateDidChange(_: Notification) {
        updateAccuracyForBatteryState()
    }

    private func updateAccuracyForBatteryState() {
        let batteryState = UIDevice.current.batteryState
        let isLowPower = ProcessInfo.processInfo.isLowPowerModeEnabled

        if batteryState == .unplugged || isLowPower {
            locationManager.desiredAccuracy = lowBatteryAccuracy
            locationManager.distanceFilter = significantDistanceChange
        } else {
            locationManager.desiredAccuracy = normalAccuracy
            locationManager.distanceFilter = significantDistanceChange / 2
        }
    }

    private func loadCachedLocation() {
        if let cachedLocation = cache.getLocation(),
           Date().timeIntervalSince(cachedLocation.timestamp) < cacheValidityDuration
        {
            location = cachedLocation
        }
    }

    // MARK: - Public Methods

    func requestWhenInUseAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

    func startUpdatingLocation() {
        error = nil
        startLocationTimeout()
        locationManager.startUpdatingLocation()

        // Start background task if needed
        if UIApplication.shared.applicationState == .background {
            startBackgroundTask()
        }
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        stopLocationTimeout()

        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }

    func requestLocation() {
        error = nil
        startLocationTimeout()
        locationManager.requestLocation()
    }

    // MARK: - Private Methods

    private func startLocationTimeout() {
        stopLocationTimeout()
        updateTimer = Timer.scheduledTimer(withTimeInterval: locationTimeout, repeats: false) { [weak self] _ in
            self?.handleLocationTimeout()
        }
    }

    private func stopLocationTimeout() {
        updateTimer?.invalidate()
        updateTimer = nil
    }

    private func handleLocationTimeout() {
        stopUpdatingLocation()
        error = .timeout
    }

    private func startBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.stopUpdatingLocation()
        }
    }

    private func handleLocationUpdate(_ newLocation: CLLocation) {
        // Validate location accuracy and age
        let locationAge = abs(newLocation.timestamp.timeIntervalSinceNow)
        guard locationAge < 30, // Location should not be older than 30 seconds
              newLocation.horizontalAccuracy >= 0,
              newLocation.horizontalAccuracy <= locationManager.desiredAccuracy
        else {
            return
        }

        // Check if the new location is significantly different
        if let currentLocation = location,
           newLocation.distance(from: currentLocation) < locationManager.distanceFilter
        {
            return
        }

        stopLocationTimeout()
        location = newLocation
        cache.saveLocation(newLocation)

        // If we have a good location, we can stop updates to save battery
        if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
            stopUpdatingLocation()
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
        case .denied:
            stopUpdatingLocation()
            error = .denied
        case .restricted:
            stopUpdatingLocation()
            error = .restricted
        case .notDetermined:
            stopUpdatingLocation()
        @unknown default:
            stopUpdatingLocation()
            error = .unavailable
        }
    }

    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        handleLocationUpdate(location)
    }

    func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        if let error = error as? CLError {
            switch error.code {
            case .denied:
                self.error = .denied
            case .locationUnknown:
                self.error = .unavailable
            default:
                self.error = .unknown(error)
            }
        } else {
            self.error = .unknown(error)
        }
    }
}

// MARK: - Location Cache

private class LocationCache {
    private let defaults = UserDefaults.standard
    private let locationKey = "cached_location"

    func saveLocation(_ location: CLLocation) {
        let data = try? NSKeyedArchiver.archivedData(withRootObject: location, requiringSecureCoding: true)
        defaults.set(data, forKey: locationKey)
    }

    func getLocation() -> CLLocation? {
        guard let data = defaults.data(forKey: locationKey),
              let location = try? NSKeyedUnarchiver.unarchivedObject(ofClass: CLLocation.self, from: data)
        else {
            return nil
        }
        return location
    }

    func clearCache() {
        defaults.removeObject(forKey: locationKey)
    }
}
