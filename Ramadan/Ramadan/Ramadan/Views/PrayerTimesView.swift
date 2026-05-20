//
//  PrayerTimesView.swift
//  Ramadan
//
//  Created by Mobi iOS on 23/02/26.
//

import SwiftUI
import CoreLocation

struct PrayerTimesView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var prayerTimes: PrayerTimes?
    @State private var manualLocation: CLLocation?
    @State private var showingLocationPicker = false
    @State private var notificationsSet = false
    
    var currentLocation: CLLocation? {
        manualLocation ?? locationManager.location
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppSpacing.md) {
                    if locationManager.authorizationStatus == .notDetermined {
                        locationPromptView
                    } else if let times = prayerTimes {
                        prayerTimesContent(times: times)
                    } else {
                        loadingView
                    }
                }
                .padding(AppSpacing.md)
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Prayer Times")
            .navigationBarItems(trailing: locationButton)
        }
        .sheet(isPresented: $showingLocationPicker) {
            ManualLocationView(selectedLocation: $manualLocation)
        }
        .onAppear {
            locationManager.requestPermission()
            NotificationManager.shared.requestPermission()
        }
        .onChange(of: currentLocation) { newLocation in
            if let location = newLocation {
                withAnimation {
                    prayerTimes = PrayerTimesCalculator.calculate(for: location)
                }
            }
        }
    }
    
    private var locationButton: some View {
        Button(action: { showingLocationPicker = true }) {
            Image(systemName: "location.fill")
                .foregroundColor(AppColors.primary)
        }
    }
    
    private var locationPromptView: some View {
        VStack(spacing: AppSpacing.lg) {
            ZStack {
                Circle()
                    .fill(AppColors.primary.opacity(0.15))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "location.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(AppColors.primary)
            }
            
            Text("Location Access Needed")
                .font(.title2.bold())
                .foregroundColor(AppColors.textPrimary)
            
            Text("We need your location to calculate accurate prayer times for your area")
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: { locationManager.requestPermission() }) {
                Text("Enable Location")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [AppColors.primary, AppColors.primary.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(AppCornerRadius.xl)
            }
            .padding(.horizontal)
        }
        .padding()
        .background(AppColors.surface)
        .cornerRadius(AppCornerRadius.xxl)
        .shadow(color: AppColors.primary.opacity(0.3), radius: 20, x: 0, y: 8)
    }
    
    private var loadingView: some View {
        VStack(spacing: AppSpacing.sm) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Calculating prayer times...")
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
    }
    
    private func prayerTimesContent(times: PrayerTimes) -> some View {
        VStack(spacing: AppSpacing.md) {
            // Next Prayer Countdown
            NextPrayerCountdown(prayerTimes: times)
            
            PrayerTimeCard(name: "Sehar", time: times.sehar, icon: "moon.stars.fill", color: AppColors.seharColor, isHighlighted: false)
            PrayerTimeCard(name: "Fajr", time: times.fajr, icon: "sunrise.fill", color: AppColors.fajrColor, isHighlighted: isCurrentPrayer(times.fajr))
            PrayerTimeCard(name: "Sunrise", time: times.sunrise, icon: "sun.max.fill", color: AppColors.sunriseColor, isHighlighted: false)
            PrayerTimeCard(name: "Dhuhr", time: times.dhuhr, icon: "sun.max.fill", color: AppColors.dhuhrColor, isHighlighted: isCurrentPrayer(times.dhuhr))
            PrayerTimeCard(name: "Asr", time: times.asr, icon: "sun.haze.fill", color: AppColors.asrColor, isHighlighted: isCurrentPrayer(times.asr))
            PrayerTimeCard(name: "Maghrib", time: times.maghrib, icon: "sunset.fill", color: AppColors.maghribColor, isHighlighted: isCurrentPrayer(times.maghrib))
            PrayerTimeCard(name: "Iftar", time: times.iftar, icon: "fork.knife", color: AppColors.iftarColor, isHighlighted: false)
            PrayerTimeCard(name: "Isha", time: times.isha, icon: "moon.stars.fill", color: AppColors.ishaColor, isHighlighted: isCurrentPrayer(times.isha))
            
            Button(action: { setupNotifications(times: times) }) {
                HStack {
                    Image(systemName: notificationsSet ? "bell.fill" : "bell")
                    Text(notificationsSet ? "Reminders Set" : "Set Reminders")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: notificationsSet ? [AppColors.primary, AppColors.primary.opacity(0.8)] : [AppColors.primary, AppColors.primary.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(AppCornerRadius.xl)
            }
            .padding(.top, AppSpacing.sm)
        }
    }
    
    private func isCurrentPrayer(_ time: Date) -> Bool {
        let now = Date()
        let calendar = Calendar.current
        let timeDiff = calendar.dateComponents([.minute], from: now, to: time).minute ?? 0
        return timeDiff >= -30 && timeDiff <= 30
    }
    
    private func setupNotifications(times: PrayerTimes) {
        NotificationManager.shared.scheduleNotification(
            title: "Sehar Time",
            body: "Time for Sehar",
            date: times.sehar,
            identifier: "sehar"
        )
        NotificationManager.shared.scheduleNotification(
            title: "Iftar Time",
            body: "Time to break your fast",
            date: times.iftar,
            identifier: "iftar"
        )
        withAnimation {
            notificationsSet = true
        }
    }
}

struct PrayerTimeCard: View {
    let name: String
    let time: Date
    let icon: String
    let color: Color
    let isHighlighted: Bool
    
    @State private var animate = false
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 56, height: 56)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(name)
                    .font(.headline)
                    .foregroundColor(AppColors.textPrimary)
                
                if isHighlighted {
                    Text("Current Prayer")
                        .font(.caption)
                        .foregroundColor(color)
                }
            }
            
            Spacer()
            
            Text(time, style: .time)
                .font(.title3.bold())
                .foregroundColor(isHighlighted ? color : AppColors.textPrimary)
        }
        .padding()
        .background(
            isHighlighted ?
            AppColors.surface :
            AppColors.surface
        )
        .cornerRadius(AppCornerRadius.xl)
        .shadow(color: color.opacity(0.3), radius: isHighlighted ? 12 : 8, x: 0, y: isHighlighted ? 4 : 2)
        .scaleEffect(animate ? 1 : 0.9)
        .opacity(animate ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(Double.random(in: 0...0.3))) {
                animate = true
            }
        }
    }
}

struct ManualLocationView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedLocation: CLLocation?
    
    @State private var latitude = ""
    @State private var longitude = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                Form {
                    Section(header: Text("Enter Coordinates").foregroundColor(AppColors.textSecondary)) {
                        TextField("Latitude", text: $latitude)
                            .keyboardType(.decimalPad)
                            .foregroundColor(AppColors.textPrimary)
                        TextField("Longitude", text: $longitude)
                            .keyboardType(.decimalPad)
                            .foregroundColor(AppColors.textPrimary)
                    }
                    
                    Section {
                        Text("Enter your location coordinates manually if automatic location is not available")
                            .font(.caption)
                            .foregroundColor(AppColors.textMuted)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Manual Location")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() }
                    .foregroundColor(AppColors.textSecondary),
                trailing: Button("Save") {
                    if let lat = Double(latitude), let lon = Double(longitude) {
                        selectedLocation = CLLocation(latitude: lat, longitude: lon)
                    }
                    dismiss()
                }
                .bold()
                .foregroundColor(AppColors.primary)
            )
        }
    }
}
