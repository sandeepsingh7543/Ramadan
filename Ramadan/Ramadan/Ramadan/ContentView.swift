//
//  ContentView.swift
//  Ramadan
//
//  Created by Mobi iOS on 23/02/26.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            // Animated gradient background
            LinearGradient(
                colors: [
                    AppColors.background,
                    AppColors.gradientStart.opacity(0.3),
                    AppColors.background
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Content area
                Group {
                    switch selectedTab {
                    case 0:
                        EnhancedDashboardView()
                    case 1:
                        DailyLogView()
                    case 2:
                        PrayerTimesView()
                    case 3:
                        QiblaCompassView()
                    case 4:
                        MessagesNotesView()
                    default:
                        EnhancedDashboardView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Custom Tab Bar
                CustomTabBar(selectedTab: $selectedTab)
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
