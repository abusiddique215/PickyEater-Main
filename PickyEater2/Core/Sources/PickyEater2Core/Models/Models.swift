import Foundation
import SwiftData

// Re-export all model types
public typealias RestaurantID = String
public typealias UserID = String
public typealias ReviewID = String

// Common constants
public enum Constants {
    public static let defaultMaxDistance: Double = 10.0 // kilometers
    public static let defaultMaximumDistance: Double = 50.0 // kilometers
    public static let defaultMinimumRating: Double = 0.0
    public static let defaultPageSize: Int = 20
} 