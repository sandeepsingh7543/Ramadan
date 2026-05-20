//
//  DailyLogView.swift
//  Ramadan
//
//  Created by Mobi iOS on 23/02/26.
//

import SwiftUI

struct DailyLogView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \DailyLog.date, ascending: false)],
        animation: .default)
    private var logs: FetchedResults<DailyLog>
    
    @State private var selectedDate = Date()
    @State private var showCalendar = false
    
    var todayLog: DailyLog? {
        let calendar = Calendar.current
        return logs.first { log in
            calendar.isDate(log.date ?? Date(), inSameDayAs: selectedDate)
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppSpacing.xxl) {
                    dateSelector
                    DailyQuoteCard()
                    progressCard
                    checklistSection
                    streakCard
                }
                .padding(AppSpacing.md)
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Daily Log")
            .sheet(isPresented: $showCalendar) {
                calendarSheet
            }
        }
    }
    
    private var dateSelector: some View {
        HStack {
            Button(action: { selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate }) {
                Image(systemName: "chevron.left")
                    .font(.title3.bold())
                    .foregroundColor(AppColors.primary)
                    .frame(width: 44, height: 44)
                    .background(AppColors.surface)
                    .cornerRadius(AppCornerRadius.md)
            }
            
            Spacer()
            
            Button(action: { showCalendar = true }) {
                VStack(spacing: AppSpacing.xs) {
                    Text(selectedDate, style: .date)
                        .font(.headline)
                    Text(selectedDate, formatter: dayFormatter)
                        .font(.caption)
                        .foregroundColor(AppColors.textMuted)
                }
                .foregroundColor(AppColors.textPrimary)
            }
            
            Spacer()
            
            Button(action: { selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate }) {
                Image(systemName: "chevron.right")
                    .font(.title3.bold())
                    .foregroundColor(AppColors.primary)
                    .frame(width: 44, height: 44)
                    .background(AppColors.surface)
                    .cornerRadius(AppCornerRadius.md)
            }
        }
    }
    
    private var progressCard: some View {
        VStack(spacing: AppSpacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today's Progress")
                        .font(.headline)
                        .foregroundColor(AppColors.textPrimary)
                    Text(selectedDate, style: .date)
                        .font(.caption)
                        .foregroundColor(AppColors.textMuted)
                }
                Spacer()
                ZStack {
                    Circle()
                        .stroke(AppColors.surface, lineWidth: 4)
                        .frame(width: 60, height: 60)
                    
                    Circle()
                        .trim(from: 0, to: completionPercentage)
                        .stroke(
                            LinearGradient(
                                colors: [AppColors.gradientStart, AppColors.gradientEnd],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: completionPercentage)
                    
                    Text("\(Int(completionPercentage * 100))%")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppColors.gradientStart, AppColors.gradientEnd],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: AppCornerRadius.md)
                        .fill(AppColors.surface)
                    
                    RoundedRectangle(cornerRadius: AppCornerRadius.md)
                        .fill(
                            LinearGradient(
                                colors: [AppColors.gradientStart, AppColors.gradientMiddle, AppColors.gradientEnd],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * completionPercentage)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: completionPercentage)
                }
            }
            .frame(height: 8)
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
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: AppColors.primary.opacity(0.2), radius: 20, x: 0, y: 10)
    }
    
    private var checklistSection: some View {
        VStack(spacing: AppSpacing.sm) {
            ChecklistItem(title: "Fajr Prayer", icon: "sunrise.fill", color: AppColors.fajrColor, isCompleted: todayLog?.fajrPrayer ?? false) {
                toggleTask(\.fajrPrayer)
            }
            ChecklistItem(title: "Dhuhr Prayer", icon: "sun.max.fill", color: AppColors.accent, isCompleted: todayLog?.dhuhrPrayer ?? false) {
                toggleTask(\.dhuhrPrayer)
            }
            ChecklistItem(title: "Asr Prayer", icon: "sun.haze.fill", color: AppColors.fajrColor, isCompleted: todayLog?.asrPrayer ?? false) {
                toggleTask(\.asrPrayer)
            }
            ChecklistItem(title: "Maghrib Prayer", icon: "sunset.fill", color: AppColors.accent, isCompleted: todayLog?.maghribPrayer ?? false) {
                toggleTask(\.maghribPrayer)
            }
            ChecklistItem(title: "Isha Prayer", icon: "moon.stars.fill", color: AppColors.fajrColor, isCompleted: todayLog?.ishaPrayer ?? false) {
                toggleTask(\.ishaPrayer)
            }
            ChecklistItem(title: "Fasting", icon: "fork.knife", color: AppColors.accent, isCompleted: todayLog?.fasting ?? false) {
                toggleTask(\.fasting)
            }
            ChecklistItem(title: "Quran Reading", icon: "book.fill", color: AppColors.fajrColor, isCompleted: todayLog?.quranReading ?? false) {
                toggleTask(\.quranReading)
            }
        }
    }
    
    private var streakCard: some View {
        HStack(spacing: AppSpacing.lg) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppColors.warning.opacity(0.3), AppColors.warning.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 70, height: 70)
                
                Image(systemName: "flame.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppColors.warning, Color.red],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("\(calculateStreak()) Days")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppColors.warning, Color.red],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                Text("Current Streak")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
        }
        .padding(AppSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppCornerRadius.xxl)
                .fill(AppColors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: AppCornerRadius.xxl)
                        .stroke(
                            LinearGradient(
                                colors: [AppColors.warning.opacity(0.3), Color.red.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: AppColors.warning.opacity(0.3), radius: 20, x: 0, y: 10)
    }
    
    private var calendarSheet: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding()
                    .accentColor(AppColors.primary)
            }
            .navigationTitle("Select Date")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") { 
                showCalendar = false 
            }
            .foregroundColor(AppColors.primary))
        }
    }
    
    private var completionPercentage: Double {
        guard let log = todayLog else { return 0 }
        let completed = [log.fajrPrayer, log.dhuhrPrayer, log.asrPrayer, log.maghribPrayer, log.ishaPrayer, log.fasting, log.quranReading].filter { $0 }.count
        return Double(completed) / 7.0
    }
    
    private func toggleTask(_ keyPath: ReferenceWritableKeyPath<DailyLog, Bool>) {
        if let log = todayLog {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                log[keyPath: keyPath].toggle()
            }
        } else {
            let newLog = DailyLog(context: viewContext)
            newLog.id = UUID()
            newLog.date = selectedDate
            newLog[keyPath: keyPath] = true
        }
        PersistenceController.shared.save()
    }
    
    private func calculateStreak() -> Int {
        let calendar = Calendar.current
        var streak = 0
        var currentDate = Date()
        
        for _ in 0..<30 {
            if let log = logs.first(where: { calendar.isDate($0.date ?? Date(), inSameDayAs: currentDate) }) {
                if log.fasting || log.fajrPrayer {
                    streak += 1
                } else {
                    break
                }
            } else {
                break
            }
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
        }
        return streak
    }
    
    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter
    }
}

struct ChecklistItem: View {
    let title: String
    let icon: String
    let color: Color
    let isCompleted: Bool
    let action: () -> Void
    
    @State private var animate = false
    
    var body: some View {
        Button(action: {
            action()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                animate.toggle()
            }
        }) {
            HStack(spacing: AppSpacing.md) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.3), color.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.body.weight(.semibold))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(
                            isCompleted ?
                            LinearGradient(
                                colors: [color, color.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [AppColors.textMuted.opacity(0.3), AppColors.textMuted.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2.5
                        )
                        .frame(width: 32, height: 32)
                    
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(color)
                            .scaleEffect(animate ? 1.2 : 1)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: animate)
                    }
                }
            }
            .padding(AppSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.xl)
                    .fill(AppColors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppCornerRadius.xl)
                            .stroke(
                                isCompleted ?
                                LinearGradient(
                                    colors: [color.opacity(0.3), color.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                LinearGradient(
                                    colors: [Color.clear, Color.clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(color: isCompleted ? color.opacity(0.3) : Color.black.opacity(0.1), radius: isCompleted ? 15 : 8, x: 0, y: isCompleted ? 6 : 2)
        }
    }
}
