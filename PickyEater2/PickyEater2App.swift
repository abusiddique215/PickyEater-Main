//
//  PickyEater2App.swift
//  PickyEater2
//
//  Created by Abu Siddique on 12/29/24.
//

import SwiftData
import SwiftUI

@main
struct PickyEater2App: App {
    @StateObject private var authService = AuthenticationService.shared
    @StateObject private var preferencesManager = PreferencesManager.shared
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authService.isAuthenticated {
                    if preferencesManager.preferences.cuisinePreferences.isEmpty {
                        CuisineSelectionView()
                            .environmentObject(preferencesManager)
                    } else {
                        MainTabView()
                            .environmentObject(preferencesManager)
                    }
                } else {
                    AuthenticationView()
                }
            }
            .environmentObject(authService)
        }
    }
}
