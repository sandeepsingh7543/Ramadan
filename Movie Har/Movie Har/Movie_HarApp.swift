//
//  Movie_HarApp.swift
//  Movie Har
//
//  Created by Mobi iOS on 10/02/26.
//

import SwiftUI
import Firebase

@main
struct Movie_HarApp: App {
    //    let persistenceController = PersistenceController.shared
    init() {
        UnityManager.shared.initializeUnityAds(gameID: "6038343")
        setupFirebaseConfiguration()
    }
    var body: some Scene {
        WindowGroup {
            PrimaryNavigationView()
            //            MainTabView()
            //                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
    func setupFirebaseConfiguration() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
    }
    
}
