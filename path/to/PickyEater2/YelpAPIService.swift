import Foundation
import CoreLocation
import MapKit
import Network

@MainActor
class YelpAPIService {
    static let shared = YelpAPIService()
    private let baseURL = "https://api.yelp.com/v3"
    private let session: URLSession
    private let decoder = JSONDecoder()
    private let apiKey: String
    private let networkMonitor: AppNetworkMonitor
    
    private init() {
        self.apiKey = ProcessInfo.processInfo.environment["YELP_API_KEY"] ?? ""
        print("📝 API Key status: \(self.apiKey.isEmpty ? "❌ Not found" : "✅ Found (\(self.apiKey.prefix(6))...)")")
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: config)
        
        // Initialize AppNetworkMonitor with explicit initialization
        self.networkMonitor = AppNetworkMonitor()
    }
    
    var isConnected: Bool {
        networkMonitor.isConnected
    }
    
    func searchRestaurants(
        near location: CLLocation,
        preferences: UserPreferences,
        searchQuery: String = "",
        offset: Int = 0
    ) async throws -> [Restaurant] {
        // Implementation remains unchanged
    }
    
    // ... rest of the code remains unchanged
} 