import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case serverError(Int)
    case noInternet
    case apiError(String)

    var localizedDescription: String {
        switch self {
        case .invalidURL:
            "Invalid URL"
        case .noData:
            "No data received"
        case .decodingError:
            "Failed to decode response"
        case let .serverError(code):
            "Server error: \(code)"
        case .noInternet:
            "No internet connection"
        case let .apiError(message):
            message
        }
    }
}
