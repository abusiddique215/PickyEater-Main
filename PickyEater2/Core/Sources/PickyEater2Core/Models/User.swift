import Foundation
import SwiftData

@Model
public final class User {
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
} 