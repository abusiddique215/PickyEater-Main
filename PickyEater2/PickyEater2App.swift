//
//  PickyEater2App.swift
//  PickyEater2
//
//  Created by Abu Siddique on 12/29/24.
//

import SwiftUI
import SwiftData

@main
struct PickyEater2App: App {
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                // 1) Start here with CuisineSelectionView
                CuisineSelectionView(preferences: .constant(UserPreferences()))
            }
            .modelContainer(for: UserPreferences.self)
            .preferredColorScheme(themeManager.colorScheme)
            .environment(\.appTheme, themeManager.colorScheme)
        }
    }
}
