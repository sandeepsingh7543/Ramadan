//
//  RamadanApp.swift
//  Ramadan
//
//  Created by Mobi iOS on 23/02/26.
//

import SwiftUI

@main
struct RamadanApp: App {
    let persistenceController = PersistenceController.shared
    
    init() {
        AppNavigationBarAppearance.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .preferredColorScheme(.dark)
        }
    }
}
