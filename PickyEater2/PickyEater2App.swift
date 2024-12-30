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
    let container: ModelContainer
    
    init() {
        do {
            let schema = Schema([
                UserPreferences.self
            ])
            let config = ModelConfiguration(schema: schema)
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            print("Error setting up SwiftData container: \(error)")
            fatalError("Could not set up SwiftData container")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container)
        }
    }
}
