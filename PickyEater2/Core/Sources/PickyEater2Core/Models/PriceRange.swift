import Foundation

public enum PriceRange: String, Codable, Hashable {
    case low = "$"
    case medium = "$$"
    case high = "$$$"
    case veryHigh = "$$$$"
    case unknown = ""
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        self = PriceRange(from: value)
    }
    
    public init(from string: String) {
        switch string.count {
        case 1: self = .low
        case 2: self = .medium
        case 3: self = .high
        case 4: self = .veryHigh
        default: self = .unknown
        }
    }
} 