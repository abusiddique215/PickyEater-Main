import Foundation

class PreferencesManager: ObservableObject {
    static let shared = PreferencesManager()
    
    @Published var userPreferences: UserPreferences = UserPreferences(
        id: UUID(),
        dietaryRestrictions: [],
        favoriteCuisines: [],
        cravings: "",
        location: "",
        isSubscribed: false,
        sortBy: .name
    )
    
    private init() {
        loadPreferences()
    }
    
    func loadPreferences() {
        if let data = UserDefaults.standard.data(forKey: "UserPreferences"),
           let decoded = try? JSONDecoder().decode(UserPreferences.self, from: data) {
            self.userPreferences = decoded
        }
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(userPreferences) {
            UserDefaults.standard.set(data, forKey: "UserPreferences")
        }
    }
    
    // Other methods...
} 