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
            CelestialView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
