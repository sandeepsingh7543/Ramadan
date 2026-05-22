import SwiftUI

struct HomeView: View {
    @StateObject private var prayerService = PrayerTimeService()
    @StateObject private var locationService = LocationService()
    @State private var timeRemaining = ""
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    HijriDateCard()
                    
                    NextPrayerCard(
                        nextPrayer: prayerService.nextPrayer,
                        timeRemaining: timeRemaining
                    )
                    
                    if let prayers = prayerService.dailyPrayers?.prayers {
                        PrayerTimesCard(prayers: prayers)
                    }
                    
                    QuickActionsGrid()
                }
                .padding()
            }
            .background(Color.theme.background.ignoresSafeArea())
            .navigationTitle("QiblaGulf")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            locationService.requestPermission()
            locationService.startUpdating()
            updatePrayerTimes()
        }
        .onChange(of: locationService.location) { _, newLocation in
            if newLocation != nil {
                updatePrayerTimes()
            }
        }
        .onReceive(timer) { _ in
            timeRemaining = prayerService.timeUntilNextPrayer()
        }
    }
    
    private func updatePrayerTimes() {
        if let location = locationService.location {
            prayerService.calculatePrayerTimes(for: location)
        }
    }
}

struct HijriDateCard: View {
    let hijriDate = HijriCalendarService.getCurrentHijriDate()
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.theme.primary.opacity(0.15))
                    .frame(width: 55, height: 55)
                
                Image(systemName: "calendar.badge.clock")
                    .font(.title2)
                    .foregroundColor(Color.theme.primary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Islamic Date")
                    .font(.caption)
                    .foregroundColor(Color.theme.textSecondary)
                Text(hijriDate.formatted)
                    .font(.headline)
                    .foregroundColor(Color.theme.textPrimary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("Today")
                    .font(.caption)
                    .foregroundColor(Color.theme.textSecondary)
                Text(Date(), style: .date)
                    .font(.subheadline)
                    .foregroundColor(Color.theme.textPrimary)
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.theme.cardBackground, Color.theme.secondary.opacity(0.05)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct NextPrayerCard: View {
    let nextPrayer: PrayerTime?
    let timeRemaining: String
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Next Prayer")
                .font(.subheadline)
                .foregroundColor(Color.theme.textSecondary)
            
            if let prayer = nextPrayer {
                Text(prayer.name.rawValue)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(Color.theme.primary)
                
                Text(timeRemaining)
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundColor(Color.theme.textPrimary)
                    .monospacedDigit()
                
                HStack(spacing: 8) {
                    Image(systemName: "clock.fill")
                        .foregroundColor(Color.theme.secondary)
                    Text(prayer.time, style: .time)
                        .font(.title2)
                        .foregroundColor(Color.theme.textSecondary)
                }
            } else {
                ProgressView()
                    .tint(Color.theme.primary)
                    .scaleEffect(1.5)
                    .padding()
                Text("Loading prayer times...")
                    .font(.subheadline)
                    .foregroundColor(Color.theme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 35)
        .background(
            LinearGradient(
                colors: [Color.theme.primary.opacity(0.1), Color.theme.accent.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .shadow(color: Color.theme.primary.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

struct PrayerTimesCard: View {
    let prayers: [PrayerTime]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "moon.stars.fill")
                    .foregroundColor(Color.theme.primary)
                Text("Today's Prayers")
                    .font(.headline)
                    .foregroundColor(Color.theme.textPrimary)
            }
            
            ForEach(prayers) { prayer in
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(prayerIconColor(for: prayer).opacity(0.15))
                            .frame(width: 45, height: 45)
                        
                        Image(systemName: prayerIcon(for: prayer.name))
                            .font(.title3)
                            .foregroundColor(prayerIconColor(for: prayer))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(prayer.name.rawValue)
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.theme.textPrimary)
                        
                        if prayer.time < Date() {
                            Text("Completed")
                                .font(.caption)
                                .foregroundColor(Color.green)
                        } else {
                            Text(timeUntil(prayer.time))
                                .font(.caption)
                                .foregroundColor(Color.theme.textSecondary)
                        }
                    }
                    
                    Spacer()
                    
                    Text(prayer.time, style: .time)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(Color.theme.textPrimary)
                }
                
                if prayer.id != prayers.last?.id {
                    Divider()
                }
            }
        }
        .padding()
        .cardStyle()
    }
    
    private func prayerIcon(for name: PrayerName) -> String {
        switch name {
        case .fajr: return "sunrise.fill"
        case .dhuhr: return "sun.max.fill"
        case .asr: return "sun.min.fill"
        case .maghrib: return "sunset.fill"
        case .isha: return "moon.stars.fill"
        }
    }
    
    private func prayerIconColor(for prayer: PrayerTime) -> Color {
        if prayer.time < Date() {
            return Color.green
        }
        switch prayer.name {
        case .fajr: return Color.orange
        case .dhuhr: return Color.yellow
        case .asr: return Color.orange
        case .maghrib: return Color.purple
        case .isha: return Color.blue
        }
    }
    
    private func timeUntil(_ date: Date) -> String {
        let interval = date.timeIntervalSince(Date())
        guard interval > 0 else { return "Now" }
        
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        
        if hours > 0 {
            return "in \(hours)h \(minutes)m"
        } else {
            return "in \(minutes)m"
        }
    }
}

struct QuickActionsGrid: View {
    let actions = [
        ("book.fill", "Quran", Color.green),
        ("location.fill", "Qibla", Color.blue),
        ("hands.sparkles.fill", "Duas", Color.purple),
        ("hand.raised.fill", "Tasbih", Color.orange)
    ]
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            ForEach(actions, id: \.1) { action in
                QuickActionButton(icon: action.0, title: action.1, color: action.2)
            }
        }
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(color)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(Color.theme.textPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .cardStyle()
    }
}
