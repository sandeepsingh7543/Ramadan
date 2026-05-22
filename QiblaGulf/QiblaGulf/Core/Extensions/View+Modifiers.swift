import SwiftUI

extension View {
    func cardStyle() -> some View {
        self
            .background(Color.theme.cardBackground)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    func primaryButton() -> some View {
        self
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.theme.primary)
            .cornerRadius(12)
    }
}
