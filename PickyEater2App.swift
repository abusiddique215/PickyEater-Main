import SwiftUI

@main
struct PickyEater2App: App {
    @StateObject private var authService = AuthenticationService.shared
    @StateObject private var preferencesManager = PreferencesManager.shared

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(authService)
                .environmentObject(preferencesManager)
        }
    }
}
