//
//  TarotApp.swift
//  Tarot
//
//  Created by Rosie O'Marrow on 12/17/24.
//

import SwiftUI
import SwiftData

@main
struct TarotApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Reading.self
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(
                for: schema,
                migrationPlan: TarotMigrationPlan.self,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
