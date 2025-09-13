//
//  AgrasandhaniApp.swift
//  Agrasandhani
//
//  Created by Akash Kumar Yadav on 13/09/25.
//

import SwiftUI

@main
struct AgrasandhaniApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var themeManager = ThemeManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(themeManager)
        }
    }
}
