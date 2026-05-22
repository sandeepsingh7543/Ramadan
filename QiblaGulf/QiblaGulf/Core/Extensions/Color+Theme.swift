import SwiftUI

extension Color {
    static let theme = ColorTheme()
}

struct ColorTheme {
    let primary = Color("PrimaryGreen", fallback: Color(hex: "228B57"))
    let secondary = Color("SecondaryGold", fallback: Color(hex: "D4AF37"))
    let background = Color("Background", fallback: Color(.systemBackground))
    let cardBackground = Color("CardBackground", fallback: Color(.secondarySystemBackground))
    let textPrimary = Color("TextPrimary", fallback: Color(.label))
    let textSecondary = Color("TextSecondary", fallback: Color(.secondaryLabel))
    let accent = Color("AccentTeal", fallback: Color(hex: "009688"))
}

extension Color {
    init(_ name: String, fallback: Color) {
        if let color = UIColor(named: name) {
            self.init(uiColor: color)
        } else {
            self = fallback
        }
    }
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
