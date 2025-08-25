//
//  CaeliscriptApp.swift
//  Caeliscript
//
//  Created by Marcell Fulop on 8/25/25.
//

import SwiftUI

@main
struct CaeliscriptApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
