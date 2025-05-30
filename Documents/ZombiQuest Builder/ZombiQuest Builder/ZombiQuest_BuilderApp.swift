//
//  ZombiQuest_BuilderApp.swift
//  ZombiQuest Builder
//
//  Created by Nash Clinton on 3/12/25.
//

import SwiftUI
import SwiftData

@main
struct ZombiQuest_BuilderApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            PDF.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MyQuestsView()
                .modelContainer(sharedModelContainer) 
        }
    }
}
