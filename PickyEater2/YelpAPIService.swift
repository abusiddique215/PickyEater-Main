import Foundation
import Network

class YelpAPIService {
    let apiKey: String
    private let baseURL = "https://api.yelp.com/v3"
    private let session: URLSession
    private let monitor: NWPathMonitor
    private var isNetworkAvailable = true
    
    init(apiKey: String) {
        // Clean and validate API key
        self.apiKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Configure URLSession with custom configuration
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        config.waitsForConnectivity = true
        config.allowsCellularAccess = true
        config.allowsExpensiveNetworkAccess = true
        config.allowsConstrainedNetworkAccess = true
        
        // Add default headers for Yelp API
        config.httpAdditionalHeaders = [
            "Authorization": "Bearer \(apiKey)",
            "Accept": "application/json"
        ]
        
        // Initialize properties
        self.monitor = NWPathMonitor()
        self.session = URLSession(configuration: config)
        self.isNetworkAvailable = true
        
        // Set up network monitor after initialization
        setupNetworkMonitor()
    }
    
    private func setupNetworkMonitor() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            if path.status == .satisfied {
                print("Network is available")
                print("Interface type: \(path.availableInterfaces.map { $0.type })")
                self.isNetworkAvailable = true
            } else {
                print("Network is not available")
                print("Path status: \(path.status)")
                self.isNetworkAvailable = false
            }
        }
        monitor.start(queue: DispatchQueue.global(qos: .background))
    }
    
    deinit {
        monitor.cancel()
    }
    
    private func convertPriceToYelpFormat(_ price: String) -> String {
        let count = price.filter { $0 == "$" }.count
        return String(count)
    }
    
    private func createRequest(latitude: Double, longitude: Double, categories: [String]?, price: String?, radius: Int?) throws -> URLRequest {
        var components = URLComponents(string: "\(baseURL)/businesses/search")!
        
        // Required parameters
        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(format: "%.6f", latitude)),
            URLQueryItem(name: "longitude", value: String(format: "%.6f", longitude)),
            URLQueryItem(name: "term", value: "restaurants"),
            URLQueryItem(name: "sort_by", value: "best_match"), // Changed from rating to best_match per docs
            URLQueryItem(name: "limit", value: "20"),
            URLQueryItem(name: "open_now", value: "true")
        ]
        
        // Optional parameters
        if let categories = categories, !categories.isEmpty {
            let cleanedCategories = categories.map { $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) }
            components.queryItems?.append(URLQueryItem(name: "categories", value: cleanedCategories.joined(separator: ",")))
        }
        
        if let price = price, !price.isEmpty {
            // Convert $$ format to 1,2,3,4 format
            let priceLevel = convertPriceToYelpFormat(price)
            components.queryItems?.append(URLQueryItem(name: "price", value: priceLevel))
        }
        
        if let radius = radius {
            // Yelp API requires radius in meters, capped at 40000
            let clampedRadius = min(max(radius, 1000), 40000)
            components.queryItems?.append(URLQueryItem(name: "radius", value: String(clampedRadius)))
        }
        
        guard let url = components.url else {
            throw APIError.invalidRequest
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Set headers according to Yelp API requirements
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Set timeouts based on Yelp's rate limits
        request.timeoutInterval = 30
        
        return request
    }
    
    func searchRestaurants(
        latitude: Double,
        longitude: Double,
        categories: [String]? = nil,
        price: String? = nil,
        radius: Int? = nil
    ) async throws -> [Restaurant] {
        guard isNetworkAvailable else {
            print("Network is not available, cannot make request")
            throw APIError.networkError(NSError(domain: "YelpAPI", code: -1009, userInfo: [NSLocalizedDescriptionKey: "No internet connection. Please check your connection and try again."]))
        }
        
        if apiKey.isEmpty {
            throw APIError.missingAPIKey
        }
        
        let request = try createRequest(
            latitude: latitude,
            longitude: longitude,
            categories: categories,
            price: price,
            radius: radius
        )
        
        print("Making request to: \(request.url?.absoluteString ?? "unknown")")
        print("Network status: \(isNetworkAvailable ? "Available" : "Not Available")")
        print("Authorization header: \(request.value(forHTTPHeaderField: "Authorization") ?? "none")")
        
        // Retry logic with longer delays
        let maxRetries = 3
        var lastError: Error?
        
        for attempt in 0...maxRetries {
            do {
                print("Starting request attempt \(attempt + 1) of \(maxRetries + 1)")
                let (data, response) = try await session.data(for: request)
                print("Received response for attempt \(attempt + 1)")
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                
                print("HTTP Status Code: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode != 200 {
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("Error Response (\(httpResponse.statusCode)): \(responseString)")
                    }
                }
                
                switch httpResponse.statusCode {
                case 200:
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let searchResponse = try decoder.decode(RestaurantSearchResponse.self, from: data)
                        print("Successfully decoded response with \(searchResponse.businesses.count) restaurants")
                        if searchResponse.businesses.isEmpty {
                            print("No restaurants found for the given criteria")
                        }
                        return searchResponse.businesses
                    } catch {
                        print("Decoding error: \(error)")
                        if let responseString = String(data: data, encoding: .utf8) {
                            print("Response data: \(responseString)")
                        }
                        throw APIError.invalidData
                    }
                case 400:
                    throw APIError.invalidRequest
                case 401:
                    print("Invalid API key or unauthorized access")
                    throw APIError.invalidAPIKey
                case 429:
                    throw APIError.rateLimitExceeded
                default:
                    throw APIError.serverError(statusCode: httpResponse.statusCode)
                }
            } catch {
                lastError = error
                print("Request attempt \(attempt + 1) failed: \(error.localizedDescription)")
                
                if attempt < maxRetries {
                    let delay = Double(attempt + 1) * 2.0 // Linear backoff: 2, 4, 6 seconds
                    print("Waiting \(delay) seconds before retry...")
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    continue
                }
                break
            }
        }
        
        if let error = lastError as? APIError {
            throw error
        } else if let error = lastError {
            print("Network error after \(maxRetries + 1) attempts: \(error)")
            throw APIError.networkError(error)
        } else {
            throw APIError.invalidResponse
        }
    }
}

// MARK: - Error Handling
extension YelpAPIService {
    enum APIError: LocalizedError {
        case missingAPIKey
        case invalidAPIKey
        case invalidResponse
        case invalidData
        case invalidRequest
        case rateLimitExceeded
        case serverError(statusCode: Int)
        case networkError(Error)
        
        var errorDescription: String? {
            switch self {
            case .missingAPIKey:
                return "API key is required. Please add your Yelp API key in the app."
            case .invalidAPIKey:
                return "The provided API key is invalid. Please check your Yelp API key at https://www.yelp.com/developers/v3/manage_app"
            case .invalidResponse:
                return "Unable to process the server response. Please try again."
            case .invalidData:
                return "The server returned invalid data. Please try again."
            case .invalidRequest:
                return "The search request was invalid. Please check your search criteria."
            case .rateLimitExceeded:
                return "You've exceeded the rate limit. Please wait a moment and try again."
            case .serverError(let statusCode):
                return "A server error occurred (Status: \(statusCode)). Please try again later."
            case .networkError(let error):
                if let urlError = error as? URLError {
                    switch urlError.code {
                    case .notConnectedToInternet:
                        return "No internet connection. Please check your connection and try again."
                    case .timedOut:
                        return "The request timed out. Please try again."
                    case .networkConnectionLost:
                        return "The network connection was lost. Please try again."
                    default:
                        return "A network error occurred: \(urlError.localizedDescription)"
                    }
                }
                return "A network error occurred: \(error.localizedDescription)"
            }
        }
    }
}

// Initialize YelpAPIService with the API key
private let yelpService: YelpAPIService = {
    // TODO: Replace with your actual Yelp API key from https://www.yelp.com/developers/v3/manage_app
    let key = "YOUR_API_KEY_HERE"
    print("Initializing YelpAPIService with key length: \(key.count)")
    return YelpAPIService(apiKey: key)
}() 