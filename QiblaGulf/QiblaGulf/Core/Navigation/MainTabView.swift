import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            PrayerView()
                .tabItem {
                    Label("Prayer", systemImage: "clock.fill")
                }
                .tag(1)
            
            QuranView()
                .tabItem {
                    Label("Quran", systemImage: "book.fill")
                }
                .tag(2)
            
            QiblaView()
                .tabItem {
                    Label("Qibla", systemImage: "location.fill")
                }
                .tag(3)
            
            MoreView()
                .tabItem {
                    Label("More", systemImage: "ellipsis.circle.fill")
                }
                .tag(4)
        }
        .accentColor(Color.theme.primary)
    }
}
