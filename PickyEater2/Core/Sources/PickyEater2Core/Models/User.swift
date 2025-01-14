import Foundation

public struct User: Codable, Identifiable {
    public let id: String
    public let email: String
    public let name: String
    public var preferences: UserPreferences
    
    public init(id: String = UUID().uuidString,
                email: String,
                name: String,
                preferences: UserPreferences = UserPreferences()) {
        self.id = id
        self.email = email
        self.name = name
        self.preferences = preferences
    }
} 