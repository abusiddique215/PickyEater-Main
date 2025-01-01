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
    init() {
        // Register value transformers
        TransformerSetup.register()
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(for: UserPreferences.self)
    }
}
