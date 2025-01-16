import Foundation

public enum YelpError: LocalizedError {
    case missingAPIKey
    case invalidURL
    case invalidResponse
    case rateLimitExceeded
    case maxRetriesExceeded
    case apiError(String)
    case decodingError(Error)
    case networkError(Error)
    
    public var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "Yelp API key is missing"
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .rateLimitExceeded:
            return "Rate limit exceeded"
        case .maxRetriesExceeded:
            return "Maximum retries exceeded"
        case .apiError(let message):
            return "API error: \(message)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
} 