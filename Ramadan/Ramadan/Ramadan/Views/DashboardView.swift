//
//  DashboardView.swift
//  Ramadan
//
//  Created by Mobi iOS on 23/02/26.
//

import SwiftUI
import Charts

struct DashboardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \DailyLog.date, ascending: false)],
        animation: .default)
    private var logs: FetchedResults<DailyLog>
    
    @State private var animateChart = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    statsSection
                }
                .padding(AppSpacing.md)
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Dashboard")
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    animateChart = true
                }
            }
        }
    }
    
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            HStack {
                Text("Your Progress")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                Image(systemName: "sparkles")
                    .font(.title2)
                    .foregroundColor(AppColors.accent)
            }
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppSpacing.md) {
                StatCardD(title: "Total Days", value: "\(logs.count)", icon: "calendar", gradient: [AppColors.gradientStart, AppColors.gradientMiddle])
                StatCardD(title: "Prayers", value: "\(completedPrayers)", icon: "moon.stars.fill", gradient: [AppColors.gradientMiddle, AppColors.gradientEnd])
                StatCardD(title: "Fasting", value: "\(fastingDays)", icon: "sun.max.fill", gradient: [AppColors.gradientEnd, AppColors.accent])
                StatCardD(title: "Quran", value: "\(quranDays)", icon: "book.fill", gradient: [AppColors.accent, AppColors.primary])
            }
        }
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
}

struct StatCardD: View {
    let title: String
    let value: String
    let icon: String
    let gradient: [Color]
    
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: gradient.map { $0.opacity(0.3) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 70, height: 70)
                
                Image(systemName: icon)
                    .font(.system(size: 30))
                    .foregroundStyle(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            Text(value)
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: gradient,
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: AppCornerRadius.xxl)
                .fill(AppColors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: AppCornerRadius.xxl)
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
        .shadow(color: gradient[0].opacity(0.3), radius: 15, x: 0, y: 8)
        .scaleEffect(animate ? 1 : 0.8)
        .opacity(animate ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                animate = true
            }
        }
    }
}
