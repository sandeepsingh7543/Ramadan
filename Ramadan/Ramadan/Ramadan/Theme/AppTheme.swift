//
//  AppTheme.swift
//  Ramadan
//
//  Created by Mobi iOS on 25/02/26.
//

import SwiftUI

// MARK: - Color Palette
struct AppColors {
    // Primary Colors - Modern Purple/Blue gradient theme
    static let primary = Color(red: 0.4, green: 0.3, blue: 0.9) // Rich Purple
    static let primaryDark = Color(red: 0.3, green: 0.2, blue: 0.7)
    static let primaryLight = Color(red: 0.5, green: 0.4, blue: 1.0)
    
    // Gradient Colors - Purple to Teal
    static let gradientStart = Color(red: 0.4, green: 0.3, blue: 0.9) // Purple
    static let gradientMiddle = Color(red: 0.3, green: 0.6, blue: 0.9) // Blue
    static let gradientEnd = Color(red: 0.2, green: 0.8, blue: 0.8) // Teal
    
    // Background Colors - Deep dark with subtle gradient
    static let background = Color(red: 0.05, green: 0.05, blue: 0.12) // Deep navy
    static let surface = Color(red: 0.1, green: 0.1, blue: 0.18) // Elevated surface
    static let surfaceLight = Color(red: 0.15, green: 0.15, blue: 0.22)
    
    // Text Colors
    static let textPrimary = Color.white
    static let textSecondary = Color(white: 0.8)
    static let textMuted = Color(white: 0.5)
    
    // Status Colors
    static let success = Color(red: 0.2, green: 0.9, blue: 0.6) // Bright green
    static let warning = Color(red: 1.0, green: 0.6, blue: 0.2) // Warm orange
    static let info = Color(red: 0.3, green: 0.7, blue: 1.0) // Sky blue
    static let accent = Color(red: 0.2, green: 0.8, blue: 0.9) // Cyan
    
    // Prayer Time Colors - Vibrant and distinct
    static let fajrColor = Color(red: 1.0, green: 0.5, blue: 0.3) // Dawn orange
    static let sunriseColor = Color(red: 1.0, green: 0.8, blue: 0.2) // Golden yellow
    static let dhuhrColor = Color(red: 1.0, green: 0.7, blue: 0.0) // Bright gold
    static let asrColor = Color(red: 1.0, green: 0.6, blue: 0.4) // Afternoon amber
    static let maghribColor = Color(red: 1.0, green: 0.3, blue: 0.4) // Sunset red
    static let ishaColor = Color(red: 0.6, green: 0.4, blue: 1.0) // Night purple
    static let seharColor = Color(red: 0.4, green: 0.5, blue: 1.0) // Pre-dawn indigo
    static let iftarColor = Color(red: 0.3, green: 0.8, blue: 0.9) // Evening teal
}

// MARK: - Typography
struct AppTypography {
    static let headline1 = Font.system(size: 32, weight: .bold, design: .default)
    static let headline2 = Font.system(size: 24, weight: .semibold, design: .default)
    static let headline3 = Font.system(size: 20, weight: .semibold, design: .default)
    static let bodyLarge = Font.system(size: 17, weight: .regular, design: .default)
    static let body = Font.system(size: 16, weight: .regular, design: .default)
    static let bodySmall = Font.system(size: 14, weight: .regular, design: .default)
    static let caption = Font.system(size: 12, weight: .medium, design: .default)
}

// MARK: - Spacing
struct AppSpacing {
    static let none = 0.0
    static let xs = 4.0
    static let sm = 8.0
    static let md = 16.0
    static let lg = 24.0
    static let xl = 32.0
    static let xxl = 48.0
}

// MARK: - Corner Radius
struct AppCornerRadius {
    static let none = 0.0
    static let xs = 4.0
    static let sm = 8.0
    static let md = 12.0
    static let lg = 16.0
    static let xl = 20.0
    static let xxl = 24.0
    static let full = 9999.0
}

// MARK: - Shadow
struct AppShadow {
    static let none = (color: Color.clear, radius: 0.0, x: 0.0, y: 0.0)
    
    static let sm = (color: Color.black.opacity(0.05), radius: 4.0, x: 0.0, y: 2.0)
    static let md = (color: Color.black.opacity(0.08), radius: 8.0, x: 0.0, y: 4.0)
    static let lg = (color: Color.black.opacity(0.12), radius: 16.0, x: 0.0, y: 8.0)
    
    static func primary(_ opacity: Double = 0.3) -> (color: Color, radius: Double, x: Double, y: Double) {
        (color: AppColors.primary.opacity(opacity), radius: 12.0, x: 0.0, y: 6.0)
    }
    
    static func colored(_ color: Color, _ opacity: Double = 0.3) -> (color: Color, radius: Double, x: Double, y: Double) {
        (color: color.opacity(opacity), radius: 12.0, x: 0.0, y: 6.0)
    }
}

// MARK: - Button Styles
struct AppButtonStyles {
    static let primary = ConfigureButtonStyle(
        backgroundColor: AppColors.primary,
        foregroundColor: .white,
        cornerRadius: AppCornerRadius.lg,
        shadow: AppShadow.primary()
    )
    
    static let secondary = ConfigureButtonStyle(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        cornerRadius: AppCornerRadius.lg,
        border: AppColors.primary.opacity(0.3)
    )
    
    static let ghost = ConfigureButtonStyle(
        backgroundColor: .clear,
        foregroundColor: AppColors.primary,
        cornerRadius: AppCornerRadius.sm
    )
}

struct ConfigureButtonStyle: ButtonStyle {
    let backgroundColor: Color
    let foregroundColor: Color
    let cornerRadius: CGFloat
    let border: Color?
    let shadow: (color: Color, radius: Double, x: Double, y: Double)?
    
    init(
        backgroundColor: Color,
        foregroundColor: Color,
        cornerRadius: CGFloat,
        border: Color? = nil,
        shadow: (color: Color, radius: Double, x: Double, y: Double)? = nil
    ) {
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.cornerRadius = cornerRadius
        self.border = border
        self.shadow = shadow
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(foregroundColor)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .shadow(color: shadow?.color ?? .clear, radius: shadow?.radius ?? 0, x: shadow?.x ?? 0, y: shadow?.y ?? 0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Card Styles
struct AppCardStyles {
    static let primary = CardStyle(
        backgroundColor: AppColors.surface,
        cornerRadius: AppCornerRadius.lg,
        shadow: AppShadow.md,
        blur: nil
    )
    
    static let elevated = CardStyle(
        backgroundColor: AppColors.surfaceLight,
        cornerRadius: AppCornerRadius.xl,
        shadow: AppShadow.lg,
        blur: nil
    )
    
    static let glass = CardStyle(
        backgroundColor: Color.black.opacity(0.3),
        cornerRadius: AppCornerRadius.lg,
        shadow: nil,
        blur: 20
    )
}

struct CardStyle {
    let backgroundColor: Color
    let cornerRadius: CGFloat
    let shadow: (color: Color, radius: Double, x: Double, y: Double)?
    let blur: CGFloat?
    
    init(
        backgroundColor: Color,
        cornerRadius: CGFloat,
        shadow: (color: Color, radius: Double, x: Double, y: Double)?,
        blur: CGFloat? = nil
    ) {
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.shadow = shadow
        self.blur = blur
    }
    
    func apply(to view: some View) -> some View {
        view
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .shadow(color: shadow?.color ?? .clear, radius: shadow?.radius ?? 0, x: shadow?.x ?? 0, y: shadow?.y ?? 0)
            .blur(radius: blur ?? 0)
    }
}

// MARK: - Navigation Bar Appearance
struct AppNavigationBarAppearance {
    static func configure() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = Color.clear.uiColor
        appearance.titleTextAttributes = [
            .foregroundColor: AppColors.textPrimary.uiColor,
            .font: UIFont.systemFont(ofSize: 20, weight: .semibold)
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: AppColors.textPrimary.uiColor,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = AppColors.primary.uiColor
        
        UITabBar.appearance().backgroundColor = Color.clear.uiColor
        UITabBar.appearance().unselectedItemTintColor = AppColors.textMuted.uiColor
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().backgroundImage = UIImage()
        
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithTransparentBackground()
        tabAppearance.stackedLayoutAppearance.selected.iconColor = AppColors.primary.uiColor
        tabAppearance.stackedLayoutAppearance.normal.iconColor = AppColors.textMuted.uiColor
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
    }
}

// MARK: - Helper Extensions
extension Color {
    var uiColor: UIColor { UIColor(self) }
}

extension View {
    func appPadding() -> some View {
        padding(AppSpacing.md)
    }
    
    func appCard() -> some View {
        background(AppColors.surface)
            .cornerRadius(AppCornerRadius.lg)
            .shadow(color: AppShadow.md.color, radius: AppShadow.md.radius, x: AppShadow.md.x, y: AppShadow.md.y)
    }
    
    func appSection() -> some View {
        padding(.bottom, AppSpacing.lg)
    }
}
