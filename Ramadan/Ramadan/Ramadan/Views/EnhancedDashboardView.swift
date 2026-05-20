//
//  EnhancedDashboardView.swift
//  Ramadan
//
//  Created by Mobi iOS on 25/02/26.
//

import SwiftUI
import Charts

struct EnhancedDashboardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \DailyLog.date, ascending: false)],
        animation: .default)
    private var logs: FetchedResults<DailyLog>
    
    @State private var animateChart = false
    @State private var selectedPeriod: TimePeriod = .week
    @State private var showShareSheet = false
    @State private var shareImage: UIImage?
    @State private var showExportOptions = false
    
    enum TimePeriod: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case all = "All Time"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    headerSection
                    statsSection
                    chartSection
                    achievementsSection
                }
                .padding(AppSpacing.md)
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Dashboard")
            .navigationBarItems(
                leading: exportButton,
                trailing: shareButton
            )
            .sheet(isPresented: $showShareSheet) {
                if let image = shareImage {
                    ShareSheet(items: [image, "Check out my Ramadan progress! 🌙"])
                }
            }
            .actionSheet(isPresented: $showExportOptions) {
                ActionSheet(
                    title: Text("Export Data"),
                    message: Text("Choose export format"),
                    buttons: [
                        .default(Text("Export as CSV")) { exportAsCSV() },
                        .default(Text("Export as JSON")) { exportAsJSON() },
                        .cancel()
                    ]
                )
            }
        }
    }
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Your Progress")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                
                Text("Keep up the great work!")
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
            
            Image(systemName: "sparkles")
                .font(.title)
                .foregroundStyle(
                    LinearGradient(
                        colors: [AppColors.warning, AppColors.accent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
    }
    
    private var statsSection: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppSpacing.md) {
            StatCard(
                title: "Total Days",
                value: "\(logs.count)",
                icon: "calendar",
                gradient: [AppColors.gradientStart, AppColors.gradientMiddle],
                subtitle: "Logged"
            )
            StatCard(
                title: "Prayers",
                value: "\(completedPrayers)",
                icon: "moon.stars.fill",
                gradient: [AppColors.gradientMiddle, AppColors.gradientEnd],
                subtitle: "Completed"
            )
            StatCard(
                title: "Fasting",
                value: "\(fastingDays)",
                icon: "sun.max.fill",
                gradient: [AppColors.gradientEnd, AppColors.accent],
                subtitle: "Days"
            )
            StatCard(
                title: "Quran",
                value: "\(quranDays)",
                icon: "book.fill",
                gradient: [AppColors.accent, AppColors.primary],
                subtitle: "Sessions"
            )
        }
    }
    
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Text("Activity Chart")
                    .font(.headline)
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                Picker("Period", selection: $selectedPeriod) {
                    ForEach(TimePeriod.allCases, id: \.self) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 200)
            }
            
            if !filteredLogs.isEmpty {
                Chart {
                    ForEach(filteredLogs, id: \.date) { log in
                        BarMark(
                            x: .value("Date", log.date ?? Date(), unit: .day),
                            y: .value("Tasks", completedTasksCount(for: log))
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppColors.primary, AppColors.accent],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .cornerRadius(4)
                    }
                }
                .frame(height: 200)
                .chartYScale(domain: 0...7)
            } else {
                emptyChartView
            }
        }
        .padding()
        .background(AppColors.surface)
        .cornerRadius(AppCornerRadius.xl)
        .shadow(color: AppColors.primary.opacity(0.2), radius: 15, x: 0, y: 8)
    }
    
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Achievements")
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.md) {
                    AchievementBadge(
                        title: "First Step",
                        icon: "star.fill",
                        isUnlocked: logs.count >= 1,
                        color: AppColors.warning
                    )
                    AchievementBadge(
                        title: "Week Warrior",
                        icon: "flame.fill",
                        isUnlocked: logs.count >= 7,
                        color: AppColors.warning
                    )
                    AchievementBadge(
                        title: "Prayer Master",
                        icon: "moon.stars.fill",
                        isUnlocked: completedPrayers >= 35,
                        color: AppColors.primary
                    )
                    AchievementBadge(
                        title: "Fasting Pro",
                        icon: "sun.max.fill",
                        isUnlocked: fastingDays >= 30,
                        color: AppColors.accent
                    )
                }
            }
        }
        .padding()
        .background(AppColors.surface)
        .cornerRadius(AppCornerRadius.xl)
        .shadow(color: AppColors.primary.opacity(0.2), radius: 15, x: 0, y: 8)
    }
    
    private var emptyChartView: some View {
        VStack(spacing: AppSpacing.sm) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 40))
                .foregroundColor(AppColors.textMuted)
            Text("No data yet")
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(height: 200)
    }
    
    private var shareButton: some View {
        Button(action: shareProgress) {
            Image(systemName: "square.and.arrow.up")
                .foregroundColor(AppColors.primary)
        }
    }
    
    private var exportButton: some View {
        Button(action: { showExportOptions = true }) {
            Image(systemName: "arrow.down.doc")
                .foregroundColor(AppColors.primary)
        }
    }
    
    private func shareProgress() {
        // Create a snapshot of the stats section
        let renderer = ImageRenderer(content: statsShareView)
        renderer.scale = 3.0
        
        if let image = renderer.uiImage {
            shareImage = image
            showShareSheet = true
        }
    }
    
    private var statsShareView: some View {
        VStack(spacing: AppSpacing.lg) {
            Text("My Ramadan Progress")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppSpacing.md) {
                StatCard(
                    title: "Total Days",
                    value: "\(logs.count)",
                    icon: "calendar",
                    gradient: [AppColors.gradientStart, AppColors.gradientMiddle],
                    subtitle: "Logged"
                )
                StatCard(
                    title: "Prayers",
                    value: "\(completedPrayers)",
                    icon: "moon.stars.fill",
                    gradient: [AppColors.gradientMiddle, AppColors.gradientEnd],
                    subtitle: "Completed"
                )
                StatCard(
                    title: "Fasting",
                    value: "\(fastingDays)",
                    icon: "sun.max.fill",
                    gradient: [AppColors.gradientEnd, AppColors.accent],
                    subtitle: "Days"
                )
                StatCard(
                    title: "Quran",
                    value: "\(quranDays)",
                    icon: "book.fill",
                    gradient: [AppColors.accent, AppColors.primary],
                    subtitle: "Sessions"
                )
            }
        }
        .padding(AppSpacing.xl)
        .background(AppColors.background)
        .frame(width: 400, height: 500)
    }
    
    private var filteredLogs: [DailyLog] {
        let calendar = Calendar.current
        let now = Date()
        
        return logs.filter { log in
            guard let date = log.date else { return false }
            
            switch selectedPeriod {
            case .week:
                return calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear)
            case .month:
                return calendar.isDate(date, equalTo: now, toGranularity: .month)
            case .all:
                return true
            }
        }
    }
    
    private func completedTasksCount(for log: DailyLog) -> Int {
        [log.fajrPrayer, log.dhuhrPrayer, log.asrPrayer, log.maghribPrayer, log.ishaPrayer, log.fasting, log.quranReading].filter { $0 }.count
    }
    
    private var completedPrayers: Int {
        logs.reduce(0) { total, log in
            total + (log.fajrPrayer ? 1 : 0) + (log.dhuhrPrayer ? 1 : 0) + (log.asrPrayer ? 1 : 0) + (log.maghribPrayer ? 1 : 0) + (log.ishaPrayer ? 1 : 0)
        }
    }
    
    private var fastingDays: Int {
        logs.filter { $0.fasting }.count
    }
    
    private var quranDays: Int {
        logs.filter { $0.quranReading }.count
    }
    
    // MARK: - Export Functions
    private func exportAsCSV() {
        var csvText = "Date,Fajr,Dhuhr,Asr,Maghrib,Isha,Fasting,Quran\n"
        
        for log in logs {
            let dateStr = log.date?.formatted(date: .abbreviated, time: .omitted) ?? ""
            csvText += "\(dateStr),\(log.fajrPrayer ? "✓" : ""),\(log.dhuhrPrayer ? "✓" : ""),\(log.asrPrayer ? "✓" : ""),\(log.maghribPrayer ? "✓" : ""),\(log.ishaPrayer ? "✓" : ""),\(log.fasting ? "✓" : ""),\(log.quranReading ? "✓" : "")\n"
        }
        
        shareTextFile(content: csvText, filename: "ramadan_log.csv")
    }
    
    private func exportAsJSON() {
        var jsonData: [[String: Any]] = []
        
        for log in logs {
            let entry: [String: Any] = [
                "date": log.date?.formatted(date: .abbreviated, time: .omitted) ?? "",
                "fajr": log.fajrPrayer,
                "dhuhr": log.dhuhrPrayer,
                "asr": log.asrPrayer,
                "maghrib": log.maghribPrayer,
                "isha": log.ishaPrayer,
                "fasting": log.fasting,
                "quran": log.quranReading
            ]
            jsonData.append(entry)
        }
        
        if let jsonString = try? JSONSerialization.data(withJSONObject: jsonData, options: .prettyPrinted),
           let jsonText = String(data: jsonString, encoding: .utf8) {
            shareTextFile(content: jsonText, filename: "ramadan_log.json")
        }
    }
    
    private func shareTextFile(content: String, filename: String) {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        
        do {
            try content.write(to: tempURL, atomically: true, encoding: .utf8)
            shareImage = nil
            showShareSheet = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
                
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootVC = windowScene.windows.first?.rootViewController {
                    rootVC.present(activityVC, animated: true)
                }
            }
        } catch {
            print("Error exporting file: \(error)")
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let gradient: [Color]
    let subtitle: String
    
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: gradient.map { $0.opacity(0.3) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.system(size: 26))
                    .foregroundStyle(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: gradient,
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            VStack(spacing: 2) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(AppColors.textPrimary)
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(AppColors.textMuted)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: AppCornerRadius.xl)
                .fill(AppColors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: AppCornerRadius.xl)
                        .stroke(
                            LinearGradient(
                                colors: gradient.map { $0.opacity(0.3) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: gradient[0].opacity(0.3), radius: 12, x: 0, y: 6)
        .scaleEffect(animate ? 1 : 0.8)
        .opacity(animate ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                animate = true
            }
        }
    }
}

struct AchievementBadge: View {
    let title: String
    let icon: String
    let isUnlocked: Bool
    let color: Color
    
    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            ZStack {
                Circle()
                    .fill(
                        isUnlocked ?
                        LinearGradient(
                            colors: [color.opacity(0.3), color.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [AppColors.textMuted.opacity(0.2), AppColors.textMuted.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isUnlocked ? color : AppColors.textMuted)
            }
            
            Text(title)
                .font(.caption2.weight(.medium))
                .foregroundColor(isUnlocked ? AppColors.textPrimary : AppColors.textMuted)
                .multilineTextAlignment(.center)
                .frame(width: 80)
        }
        .opacity(isUnlocked ? 1 : 0.5)
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
