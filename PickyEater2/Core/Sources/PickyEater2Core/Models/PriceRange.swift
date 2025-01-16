import Foundation

public enum PriceRange: String, Codable, CaseIterable, Sendable {
    case low = "$"
    case medium = "$$"
    case high = "$$$"
    case veryHigh = "$$$$"
    case unknown = ""
    
    public init(rawValue: Int) {
        switch rawValue {
        case 1: self = .low
        case 2: self = .medium
        case 3: self = .high
        case 4: self = .veryHigh
        default: self = .unknown
        }
    }
    
    public var description: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        case .veryHigh: return "Very High"
        case .unknown: return "Unknown"
        }
    }
} 