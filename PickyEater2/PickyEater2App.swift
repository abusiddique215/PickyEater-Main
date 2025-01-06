//
//  PickyEater2App.swift
//  PickyEater2
//
//  Created by Abu Siddique on 12/29/24.
//

import SwiftUI

@main
struct PickyEater2App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var notificationManager = NotificationManager.shared
    
    var body: some Scene {
        WindowGroup {
            CuisineSelectionView()
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
