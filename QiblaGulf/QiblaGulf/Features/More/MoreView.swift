import SwiftUI

struct MoreView: View {
    var body: some View {
        NavigationView {
            List {
                // Islamic Tools Section
                Section(header: Text("Islamic Tools")) {
                    NavigationLink(destination: TasbihView()) {
                        MenuRow(icon: "hand.raised.fill", title: "Tasbih Counter", color: .orange)
                    }
                    
                    NavigationLink(destination: DuasView()) {
                        MenuRow(icon: "hands.sparkles.fill", title: "Duas & Supplications", color: .purple)
                    }
                    
//                    NavigationLink(destination: HadithView()) {
//                        MenuRow(icon: "book.closed.fill", title: "Hadith Collection", color: .brown)
//                    }
//                    
//                    NavigationLink(destination: MosqueFinderView()) {
//                        MenuRow(icon: "building.columns.fill", title: "Nearby Mosques", color: .green)
//                    }
                }
                
                // Settings Section
//                Section(header: Text("Settings")) {
//                    NavigationLink(destination: Text("Notifications")) {
//                        MenuRow(icon: "bell.fill", title: "Notifications", color: .blue)
//                    }
//                    
//                    NavigationLink(destination: Text("Appearance")) {
//                        MenuRow(icon: "paintbrush.fill", title: "Appearance", color: .pink)
//                    }
//                    
//                    NavigationLink(destination: Text("Language")) {
//                        MenuRow(icon: "globe", title: "Language", color: .cyan)
//                    }
//                }
                
                // About Section
//                Section(header: Text("About")) {
//                    NavigationLink(destination: Text("About")) {
//                        MenuRow(icon: "info.circle.fill", title: "About QiblaGulf", color: .gray)
//                    }
//                    
//                    NavigationLink(destination: Text("Share")) {
//                        MenuRow(icon: "square.and.arrow.up.fill", title: "Share App", color: .indigo)
//                    }
//                }
            }
            .navigationTitle("More")
        }
    }
}

struct MenuRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(title)
                .foregroundColor(Color.theme.textPrimary)
        }
    }
}

// Tasbih Counter View
struct TasbihView: View {
    @State private var count = 0
    @State private var target = 33
    @State private var showCelebration = false
    
    var progress: Double {
        Double(count) / Double(target)
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.theme.background, Color.theme.primary.opacity(0.1)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Progress Ring
                ZStack {
                    Circle()
                        .stroke(Color.theme.primary.opacity(0.2), lineWidth: 15)
                        .frame(width: 200, height: 200)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            LinearGradient(
                                colors: [Color.theme.primary, Color.theme.accent],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 15, lineCap: .round)
                        )
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 0.5), value: count)
                    
                    VStack(spacing: 8) {
                        Text("\(count)")
                            .font(.system(size: 60, weight: .bold, design: .rounded))
                            .foregroundColor(Color.theme.primary)
                        
                        Text("of \(target)")
                            .font(.title3)
                            .foregroundColor(Color.theme.textSecondary)
                    }
                }
                .padding(.top, 40)
                
                // Counter Button
                Button(action: {
                    incrementCount()
                }) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.theme.primary, Color.theme.accent],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 180, height: 180)
                            .shadow(color: Color.theme.primary.opacity(0.4), radius: 20, x: 0, y: 10)
                        
                        VStack(spacing: 8) {
                            Image(systemName: "hand.tap.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                            
                            Text("TAP")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
                }
                .scaleEffect(showCelebration ? 1.1 : 1.0)
                .animation(.spring(response: 0.3), value: showCelebration)
                
                // Controls
                VStack(spacing: 16) {
                    HStack(spacing: 20) {
                        Button(action: { count = 0 }) {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                Text("Reset")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(12)
                        }
                        
                        Menu {
                            Button("33") { target = 33 }
                            Button("99") { target = 99 }
                            Button("100") { target = 100 }
                            Button("1000") { target = 1000 }
                        } label: {
                            HStack {
                                Image(systemName: "target")
                                Text("Target: \(target)")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.theme.primary)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Stats
                    HStack(spacing: 20) {
                        StatCard(title: "Remaining", value: "\(max(0, target - count))")
                        StatCard(title: "Progress", value: "\(Int(progress * 100))%")
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
        }
        .navigationTitle("Tasbih Counter")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func incrementCount() {
        count += 1
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        if count >= target {
            showCelebration = true
            let notificationGenerator = UINotificationFeedbackGenerator()
            notificationGenerator.notificationOccurred(.success)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showCelebration = false
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(Color.theme.textSecondary)
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(Color.theme.primary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.theme.cardBackground)
        .cornerRadius(12)
    }
}

// Duas View
struct DuasView: View {
    let duas = [
        Dua(title: "Morning Dua", arabicText: "أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ", transliteration: "Asbahna wa asbahal mulku lillah", translation: "We have entered a new day and the dominion belongs to Allah", reference: "Muslim"),
        Dua(title: "Before Eating", arabicText: "بِسْمِ اللَّهِ", transliteration: "Bismillah", translation: "In the name of Allah", reference: "Bukhari"),
        Dua(title: "After Eating", arabicText: "الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا", transliteration: "Alhamdulillahil-ladhi at'amana", translation: "Praise be to Allah who has fed us", reference: "Abu Dawud")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(duas) { dua in
                    DuaCard(dua: dua)
                }
            }
            .padding()
        }
        .background(Color.theme.background.ignoresSafeArea())
        .navigationTitle("Duas")
    }
}

struct DuaCard: View {
    let dua: Dua
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(dua.title)
                .font(.headline)
                .foregroundColor(Color.theme.primary)
            
            Text(dua.arabicText)
                .font(.title2)
                .foregroundColor(Color.theme.textPrimary)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
            
            Text(dua.transliteration)
                .font(.subheadline)
                .italic()
                .foregroundColor(Color.theme.textSecondary)
            
            Text(dua.translation)
                .font(.body)
                .foregroundColor(Color.theme.textPrimary)
            
            Text("Reference: \(dua.reference)")
                .font(.caption)
                .foregroundColor(Color.theme.textSecondary)
        }
        .padding()
        .cardStyle()
    }
}

// Hadith View
struct HadithView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Hadith collection coming soon")
                    .foregroundColor(Color.theme.textSecondary)
                    .padding()
            }
        }
        .background(Color.theme.background.ignoresSafeArea())
        .navigationTitle("Hadith")
    }
}

// Mosque Finder View
struct MosqueFinderView: View {
    var body: some View {
        ZStack {
            Color.theme.background.ignoresSafeArea()
            
            VStack {
                Text("Mosque finder with map integration")
                    .foregroundColor(Color.theme.textSecondary)
                Text("Coming soon")
                    .font(.caption)
                    .foregroundColor(Color.theme.textSecondary)
            }
        }
        .navigationTitle("Nearby Mosques")
    }
}
