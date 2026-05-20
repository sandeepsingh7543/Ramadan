//
//  NextPrayerCountdown.swift
//  Ramadan
//
//  Created by Mobi iOS on 25/02/26.
//

import SwiftUI

struct NextPrayerCountdown: View {
    let prayerTimes: PrayerTimes
    @State private var timeRemaining: TimeInterval = 0
    @State private var nextPrayerName: String = ""
    @State private var nextPrayerTime: Date = Date()
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: AppSpacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Next Prayer")
                        .font(.caption.weight(.medium))
                        .foregroundColor(AppColors.textSecondary)
                    
                    Text(nextPrayerName)
                        .font(.title2.weight(.bold))
                        .foregroundColor(AppColors.textPrimary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Time Remaining")
                        .font(.caption.weight(.medium))
                        .foregroundColor(AppColors.textSecondary)
                    
                    Text(timeString)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppColors.primary, AppColors.accent],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .monospacedDigit()
                }
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: AppCornerRadius.sm)
                        .fill(AppColors.surface)
                    
                    RoundedRectangle(cornerRadius: AppCornerRadius.sm)
                        .fill(
                            LinearGradient(
                                colors: [AppColors.primary, AppColors.accent],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress)
                        .animation(.linear(duration: 1), value: progress)
                }
            }
            .frame(height: 6)
        }
        .padding(AppSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppCornerRadius.xxl)
                .fill(AppColors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: AppCornerRadius.xxl)
                        .stroke(
                            LinearGradient(
                                colors: [AppColors.primary.opacity(0.3), AppColors.accent.opacity(0.3)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: AppColors.primary.opacity(0.2), radius: 20, x: 0, y: 10)
        .onAppear {
            updateNextPrayer()
        }
        .onReceive(timer) { _ in
            updateTimeRemaining()
        }
    }
    
    private var timeString: String {
        let hours = Int(timeRemaining) / 3600
        let minutes = Int(timeRemaining) / 60 % 60
        let seconds = Int(timeRemaining) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    private var progress: Double {
        guard timeRemaining > 0 else { return 0 }
        let totalTime = nextPrayerTime.timeIntervalSince(Date()) + timeRemaining
        return 1 - (timeRemaining / totalTime)
    }
    
    private func updateNextPrayer() {
        let now = Date()
        let prayers: [(String, Date)] = [
            ("Fajr", prayerTimes.fajr),
            ("Dhuhr", prayerTimes.dhuhr),
            ("Asr", prayerTimes.asr),
            ("Maghrib", prayerTimes.maghrib),
            ("Isha", prayerTimes.isha)
        ]
        
        // Find next prayer
        if let next = prayers.first(where: { $0.1 > now }) {
            nextPrayerName = next.0
            nextPrayerTime = next.1
        } else {
            // If all prayers passed, show tomorrow's Fajr
            nextPrayerName = "Fajr"
            nextPrayerTime = Calendar.current.date(byAdding: .day, value: 1, to: prayerTimes.fajr) ?? prayerTimes.fajr
        }
        
        updateTimeRemaining()
    }
    
    private func updateTimeRemaining() {
        timeRemaining = max(0, nextPrayerTime.timeIntervalSince(Date()))
        
        if timeRemaining == 0 {
            updateNextPrayer()
        }
    }
}
