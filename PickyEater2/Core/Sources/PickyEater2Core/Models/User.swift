import Foundation
import SwiftData

@Model
public final class User: Codable {
    public var id: String
    public var email: String
    public var name: String
    @Relationship public var preferences: UserPreferences
    
    public init(id: String, email: String, name: String, preferences: UserPreferences) {
        self.id = id
        self.email = email
        self.name = name
        self.preferences = preferences
    }
    
    // MARK: - Codable
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case name
        case preferences
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        email = try container.decode(String.self, forKey: .email)
        name = try container.decode(String.self, forKey: .name)
        preferences = try container.decode(UserPreferences.self, forKey: .preferences)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(email, forKey: .email)
        try container.encode(name, forKey: .name)
        try container.encode(preferences, forKey: .preferences)
    }
} 