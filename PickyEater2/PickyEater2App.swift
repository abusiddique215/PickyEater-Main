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
            ContentView()
                .modelContainer(for: UserPreferences.self)
                .preferredColorScheme(themeManager.colorScheme)
                .environment(\.appTheme, themeManager.colorScheme)
        }
    }
}
