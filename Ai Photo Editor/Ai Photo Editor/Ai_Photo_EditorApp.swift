import SwiftUI
import Firebase

@main
struct Ai_Photo_EditorApp: App {
    init() {
        UnityManager.shared.initializeUnityAds(gameID: "6038343")
        setupFirebaseConfiguration()
    }
    var body: some Scene {
        WindowGroup {
            PrimaryNavigationView()
        }
    }
    func setupFirebaseConfiguration() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
    }
}
