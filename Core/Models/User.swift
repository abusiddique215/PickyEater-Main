import Foundation

struct User: Codable, Identifiable {
    let id: String
    let name: String
    let email: String
    // Additional user properties...
} 