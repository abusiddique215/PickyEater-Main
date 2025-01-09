import Foundation

class PreferencesManager: ObservableObject {
    static let shared = PreferencesManager()
    
    private init() {
        // Initialization logic...
    }
    
    @Published var userPreferences: UserPreferences = UserPreferences(
        id: UUID(),
        dietaryRestrictions: [],
        favoriteCuisines: [],
        cravings: "",
        location: "",
        isSubscribed: false,
        sortBy: .name
    )
    
    func save() {
        // Save logic...
    }
    
    // Other preferences management methods...
} 