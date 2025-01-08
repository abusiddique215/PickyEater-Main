import SwiftData
import SwiftUI

@MainActor
class PreferencesManager: ObservableObject {
    static let shared = PreferencesManager()
    @Published var currentPreferences: UserPreferences

    private init() {
        // Load default preferences or from storage
        currentPreferences = UserPreferences()
        loadPreferences()
    }

    private func loadPreferences() {
        // Load preferences from UserDefaults or other storage
        if let data = UserDefaults.standard.data(forKey: "userPreferences"),
           let preferences = try? JSONDecoder().decode(UserPreferences.self, from: data)
        {
            currentPreferences = preferences
        }
    }

    func savePreferences() {
        if let data = try? JSONEncoder().encode(currentPreferences) {
            UserDefaults.standard.set(data, forKey: "userPreferences")
        }
    }

    func updatePreferences(_ preferences: UserPreferences) {
        currentPreferences = preferences
        savePreferences()
    }
}
