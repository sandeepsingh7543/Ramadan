//
//  QiblaGulfApp.swift
//  QiblaGulf
//
//  Created by Mobi iOS on 09/01/26.
//

import SwiftUI
import Firebase

@main
struct QiblaGulfApp: App {
    
    init() {
        UnityManager.shared.initializeUnityAds(gameID: "6030018")
        setupFirebaseConfiguration()
    }
    
    var body: some Scene {
        WindowGroup {
            A0()
        }
    }
    func setupFirebaseConfiguration() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
    }
}
