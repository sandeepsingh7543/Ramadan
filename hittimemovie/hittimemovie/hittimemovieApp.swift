//
//  hittimemovieApp.swift
//  CinemaVault
//
//  Created by Mobi iOS on 31/10/25.
//

import SwiftUI
import Firebase

@main
struct CinemaVaultApp: App {
    init() {
        configureFirebase()
    }
    
    var body: some Scene {
        WindowGroup {
            A0()
//            ContentView()
        }
    }
    func configureFirebase() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
    }
}
