import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            MovieJournalView()
                .tabItem {
                    Label("Journal", systemImage: "book.fill")
                }
            
            FilmCreatorView()
                .tabItem {
                    Label("Create", systemImage: "lightbulb.fill")
                }
        }
        .preferredColorScheme(.dark)
    }
}
