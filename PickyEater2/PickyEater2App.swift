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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                CuisineSelectionView()
            }
            .modelContainer(for: UserPreferences.self)
            .preferredColorScheme(themeManager.colorScheme)
            .environment(\.appTheme, themeManager.colorScheme)
            .onAppear {
                // Request notification permissions when app launches
                Task {
                    do {
                        try await notificationManager.requestPermission()
                    } catch {
                        print("Failed to request notification permission: \(error)")
                    }
                }
            }
        }
    }
}
