import Foundation
import SwiftData

public struct User: Codable, Identifiable {
    public let id: String
    public let email: String
    public let name: String
    public var preferences: UserPreferences

    private enum CodingKeys: String, CodingKey {
        case id, email, name
    }

    public init(id: String = UUID().uuidString,
                email: String,
                name: String,
                preferences: UserPreferences = UserPreferences())
    {
        self.id = id
        self.email = email
        self.name = name
        self.preferences = preferences
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        email = try container.decode(String.self, forKey: .email)
        name = try container.decode(String.self, forKey: .name)
        preferences = UserPreferences()
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(email, forKey: .email)
        try container.encode(name, forKey: .name)
    }
}
