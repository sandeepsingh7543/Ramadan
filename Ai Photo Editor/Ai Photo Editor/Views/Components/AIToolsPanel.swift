import SwiftUI

struct AIToolsPanel: View {
    @ObservedObject var viewModel: PhotoEditorViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("AI Tools")
                .font(.headline)
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .padding(.top)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                AIToolCard(icon: "person.crop.circle.badge.minus", title: "Remove BG", color: .blue) {
                    viewModel.removeBackground()
                }
                
                AIToolCard(icon: "sparkles", title: "Enhance", color: .green) {
                    viewModel.brightness = 0.15
                    viewModel.contrast = 1.25
                    viewModel.saturation = 1.15
                    viewModel.applyAdjustments()
                }
                
                AIToolCard(icon: "circle.dotted", title: "Blur BG", color: .purple) {
                    viewModel.blurAmount = 20
                    viewModel.applyBlur()
                }
                
                AIToolCard(icon: "wand.and.stars", title: "Smart Fix", color: .orange) {
                    viewModel.brightness = 0.1
                    viewModel.contrast = 1.2
                    viewModel.saturation = 1.1
                    viewModel.applyAdjustments()
                }
                
                AIToolCard(icon: "sun.max", title: "Brighten", color: .yellow) {
                    viewModel.brightness = 0.3
                    viewModel.applyAdjustments()
                }
                
                AIToolCard(icon: "moon.stars", title: "Darken", color: .indigo) {
                    viewModel.brightness = -0.2
                    viewModel.applyAdjustments()
                }
            }
            .padding(.horizontal)
        }
    }
}

struct AIToolCard: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [color.opacity(0.8), color.opacity(0.6)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(12)
            .shadow(color: color.opacity(0.3), radius: 4, y: 2)
        }
    }
}
