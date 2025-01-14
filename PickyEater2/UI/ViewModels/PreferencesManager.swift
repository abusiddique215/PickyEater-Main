import SwiftUI
import Foundation
import PickyEater2Core

@MainActor
class PreferencesManager: ObservableObject {
    static let shared = PreferencesManager()

    @Published var userPreferences: UserPreferences = UserPreferences()

    private init() {
        loadPreferences()
    }

    func loadPreferences() {
        if let data = UserDefaults.standard.data(forKey: "UserPreferences"),
           let decoded = try? JSONDecoder().decode(UserPreferences.self, from: data)
        {
            userPreferences = decoded
        }
    }

    func save() {
        if let encoded = try? JSONEncoder().encode(userPreferences) {
            UserDefaults.standard.set(encoded, forKey: "UserPreferences")
        }
    }
}
