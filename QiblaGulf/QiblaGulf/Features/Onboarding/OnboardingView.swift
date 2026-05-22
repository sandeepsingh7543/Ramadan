import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @Binding var isOnboardingComplete: Bool
    @State private var showMainTab = false // <-- yahi state chahiye
    var body: some View {
        ZStack {
            Color.theme.background.ignoresSafeArea()
            
            VStack(spacing: 40) {
                TabView(selection: $currentPage) {
                    OnboardingPage(
                        icon: "clock.fill",
                        title: "Never Miss Prayer",
                        description: "Get accurate prayer times based on your location with beautiful azan notifications"
                    ).tag(0)
                    
                    OnboardingPage(
                        icon: "book.fill",
                        title: "Read Holy Quran",
                        description: "Access complete Quran with translations, audio recitation, and bookmarks"
                    ).tag(1)
                    
                    OnboardingPage(
                        icon: "location.fill",
                        title: "Find Qibla Direction",
                        description: "Accurate compass to help you find the direction of Kaaba from anywhere"
                    ).tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                
                Button(action: {
                    if currentPage < 2 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                       showMainTab = true // <-- yahi pe call
                        isOnboardingComplete = true
                    }
                }) {
                    Text(currentPage < 2 ? "Continue" : "Get Started")
                        .primaryButton()
                }
                .padding(.horizontal, 32)
            }
        }
        .fullScreenCover(isPresented: $showMainTab) {
            MainTabView() // <-- yahi screen pe show hoga
        }
    }
}

struct OnboardingPage: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: icon)
                .font(.system(size: 80))
                .foregroundColor(Color.theme.primary)
            
            VStack(spacing: 16) {
                Text(title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color.theme.textPrimary)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(Color.theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
    }
}
