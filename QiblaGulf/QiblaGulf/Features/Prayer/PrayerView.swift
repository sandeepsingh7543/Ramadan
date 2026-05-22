import SwiftUI

struct PrayerView: View {
    @StateObject private var prayerService = PrayerTimeService()
    @StateObject private var locationService = LocationService()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    if let current = prayerService.dailyPrayers?.currentPrayer() {
                        CurrentPrayerBanner(prayer: current)
                    }
                    
                    if let prayers = prayerService.dailyPrayers?.prayers {
                        ForEach(prayers) { prayer in
                            PrayerTimeRow(prayer: prayer)
                        }
                    } else {
                        Text("Loading prayer times...")
                            .foregroundColor(Color.theme.textSecondary)
                            .padding()
                    }
                    
                    PrayerSettingsSection()
                }
                .padding()
            }
            .background(Color.theme.background.ignoresSafeArea())
            .navigationTitle("Prayer Times")
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
    }
    
    private func updatePrayerTimes() {
        if let location = locationService.location {
            prayerService.calculatePrayerTimes(for: location)
        }
    }
}

struct CurrentPrayerBanner: View {
    let prayer: PrayerTime
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Current Prayer")
                    .font(.caption)
                    .foregroundColor(Color.theme.textSecondary)
                
                Text(prayer.name.rawValue)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(.white)
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.theme.primary, Color.theme.accent],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }
}

struct PrayerTimeRow: View {
    let prayer: PrayerTime
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon with gradient background
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [iconColor(for: prayer.name), iconColor(for: prayer.name).opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 55, height: 55)
                    .shadow(color: iconColor(for: prayer.name).opacity(0.3), radius: 5)
                
                Image(systemName: prayerIcon(for: prayer.name))
                    .font(.title2)
                    .foregroundColor(.white)
            }
            
            // Prayer Info
            VStack(alignment: .leading, spacing: 6) {
                Text(prayer.name.rawValue)
                    .font(.headline)
                    .foregroundColor(Color.theme.textPrimary)
                
                HStack(spacing: 8) {
                    if prayer.time < Date() {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                        Text("Completed")
                            .font(.caption)
                            .foregroundColor(.green)
                    } else {
                        Image(systemName: "clock.fill")
                            .font(.caption)
                            .foregroundColor(Color.theme.secondary)
                        Text(timeDescription(for: prayer))
                            .font(.caption)
                            .foregroundColor(Color.theme.textSecondary)
                    }
                }
            }
            
            Spacer()
            
            // Time
            VStack(alignment: .trailing, spacing: 4) {
                Text(prayer.time, style: .time)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.theme.textPrimary)
                
                if prayer.time > Date() {
                    Text(shortTimeUntil(prayer.time))
                        .font(.caption2)
                        .foregroundColor(Color.theme.textSecondary)
                }
            }
        }
        .padding()
        .background(Color.theme.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
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
    
    private func iconColor(for name: PrayerName) -> Color {
        switch name {
        case .fajr: return Color.orange
        case .dhuhr: return Color.yellow
        case .asr: return Color.orange.opacity(0.8)
        case .maghrib: return Color.purple
        case .isha: return Color.blue
        }
    }
    
    private func timeDescription(for prayer: PrayerTime) -> String {
        let interval = prayer.time.timeIntervalSince(Date())
        guard interval > 0 else { return "Now" }
        
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        
        if hours > 0 {
            return "in \(hours) hour\(hours > 1 ? "s" : "") \(minutes) min"
        } else if minutes > 0 {
            return "in \(minutes) minute\(minutes > 1 ? "s" : "")"
        } else {
            return "Starting soon"
        }
    }
    
    private func shortTimeUntil(_ date: Date) -> String {
        let interval = date.timeIntervalSince(Date())
        guard interval > 0 else { return "" }
        
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

struct PrayerSettingsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Settings")
                .font(.headline)
                .foregroundColor(Color.theme.textPrimary)
            
            SettingRow(icon: "bell.fill", title: "Azan Notifications", value: "Enabled")
            SettingRow(icon: "speaker.wave.2.fill", title: "Azan Sound", value: "Makkah")
            SettingRow(icon: "clock.fill", title: "Calculation Method", value: "MWL")
        }
        .padding()
        .cardStyle()
    }
}

struct SettingRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color.theme.primary)
            
            Text(title)
                .font(.body)
                .foregroundColor(Color.theme.textPrimary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(Color.theme.textSecondary)
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(Color.theme.textSecondary)
        }
    }
}
