import SwiftUI

@main
struct PickyEater2App: App {
    @StateObject private var authService = AuthenticationService.shared
    @StateObject private var userPreferences = UserPreferences()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authService)
                .environmentObject(userPreferences)
        }
    }
} 