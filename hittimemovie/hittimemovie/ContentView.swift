import SwiftUI

struct ContentView: View {
    @StateObject private var movieManager = MovieManager()
    @State private var selectedTab = 0
    @State private var showSplash = true
    
    var body: some View {
        ZStack {
            if showSplash {
                SplashView()
                    .transition(.opacity)
            } else {
                MainAppView(selectedTab: $selectedTab)
                    .environmentObject(movieManager)
                    .transition(.opacity)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut(duration: 1.0)) {
                    showSplash = false
                }
            }
        }
    }
}

struct SplashView: View {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "film.stack")
                    .font(.system(size: 80, weight: .thin))
                    .foregroundColor(.white)
                    .scaleEffect(scale)
                    .opacity(opacity)
                
                Text("CinemaVault")
                    .font(.system(size: 32, weight: .ultraLight, design: .rounded))
                    .foregroundColor(.white)
                    .opacity(opacity)
                
                Text("Your Personal Movie Universe")
                    .font(.system(size: 14, weight: .light))
                    .foregroundColor(.white.opacity(0.7))
                    .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.5)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}

struct MainAppView: View {
    @Binding var selectedTab: Int
    @EnvironmentObject var movieManager: MovieManager
    
    var body: some View {
        ZStack {
            // Dynamic background
            AnimatedBackground()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Content area
                Group {
                    switch selectedTab {
                    case 0: DiscoverView()
                    case 1: MyVaultView()
                    case 2: TicketsView()
                    case 3: WatchlistView()
                    case 4: ProfileView()
                    default: DiscoverView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Custom floating tab bar
                FloatingTabBar(selectedTab: $selectedTab)
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct AnimatedBackground: View {
    var body: some View {
        Color.black
            .ignoresSafeArea()
    }
}

struct FloatingTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 0) {
            TabButton(icon: "sparkles", title: "Discover", index: 0, selectedTab: $selectedTab)
            TabButton(icon: "archivebox.fill", title: "Vault", index: 1, selectedTab: $selectedTab)
            TabButton(icon: "ticket.fill", title: "Tickets", index: 2, selectedTab: $selectedTab)
            TabButton(icon: "heart.fill", title: "Watchlist", index: 3, selectedTab: $selectedTab)
            TabButton(icon: "person.crop.circle", title: "Profile", index: 4, selectedTab: $selectedTab)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal, 30)
        .padding(.bottom, 40)
    }
}

struct TabButton: View {
    let icon: String
    let title: String
    let index: Int
    @Binding var selectedTab: Int
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = index
            }
        }) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: selectedTab == index ? 22 : 18, weight: .medium))
                    .foregroundColor(selectedTab == index ? .purple : .white.opacity(0.6))
                    .scaleEffect(selectedTab == index ? 1.2 : 1.0)
                
                Text(title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(selectedTab == index ? .purple : .white.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(selectedTab == index ? Color.purple.opacity(0.2) : Color.clear)
                    .scaleEffect(selectedTab == index ? 1.0 : 0.8)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ContentView()
}
