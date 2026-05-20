//
//  CustomTabBar.swift
//  Ramadan
//
//  Created by Mobi iOS on 25/02/26.
//

import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    let tabs: [(icon: String, title: String, color: Color)] = [
        ("chart.bar.fill", "Dashboard", AppColors.primary),
        ("checkmark.circle.fill", "Daily Log", AppColors.accent),
        ("clock.fill", "Prayer", AppColors.warning),
        ("location.north.fill", "Qibla", AppColors.success),
        ("square.and.pencil", "Notes", AppColors.info)
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                TabBarButton(
                    icon: tabs[index].icon,
                    title: tabs[index].title,
                    color: tabs[index].color,
                    isSelected: selectedTab == index
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = index
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .background(
            ZStack {
                // Blur effect
                RoundedRectangle(cornerRadius: 28)
                    .fill(AppColors.surface.opacity(0.95))
                    .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: -5)
                
                // Gradient border
                RoundedRectangle(cornerRadius: 28)
                    .stroke(
                        LinearGradient(
                            colors: [
                                AppColors.primary.opacity(0.3),
                                AppColors.accent.opacity(0.3)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 1
                    )
            }
            .background(Color(.clear))
        )
        .background(Color(.clear))
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}

struct TabBarButton: View {
    let icon: String
    let title: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            action()
            // Haptic feedback
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
        }) {
            VStack(spacing: 6) {
                ZStack {
                    if isSelected {
                        // Animated background for selected tab
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [color.opacity(0.3), color.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50, height: 50)
                            .scaleEffect(isPressed ? 0.9 : 1.0)
                    }
                    
                    Image(systemName: icon)
                        .font(.system(size: isSelected ? 24 : 20, weight: .semibold))
                        .foregroundStyle(
                            isSelected ?
                            LinearGradient(
                                colors: [color, color.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [AppColors.textMuted, AppColors.textMuted],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(isPressed ? 0.85 : 1.0)
                }
                .frame(height: 50)
                
                Text(title)
                    .font(.system(size: isSelected ? 11 : 10, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? color : AppColors.textMuted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(TabButtonStyle(isPressed: $isPressed))
    }
}

struct TabButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { newValue in
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = newValue
                }
            }
    }
}

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        
        VStack {
            Spacer()
            CustomTabBar(selectedTab: .constant(0))
        }
    }
}
