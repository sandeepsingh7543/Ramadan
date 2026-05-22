import SwiftUI

struct EffectsView: View {
    @ObservedObject var viewModel: PhotoEditorViewModel
    @State private var blurChanged = false
    @State private var vignetteChanged = false
    @State private var noiseChanged = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Effects")
                .font(.headline)
                .foregroundColor(colorScheme == .dark ? .white : .black)
            
            VStack(spacing: 12) {
                EffectSlider(title: "Blur Background", value: $viewModel.blurAmount, range: 0...50) {
                    blurChanged = true
                    viewModel.applyBlur()
                }
                
                EffectSlider(title: "Vignette", value: $viewModel.vignetteAmount, range: 0...1) {
                    vignetteChanged = true
                    viewModel.applyVignette()
                }
                
                EffectSlider(title: "Noise Reduction", value: $viewModel.noiseReduction, range: 0...1) {
                    noiseChanged = true
                    viewModel.applyNoiseReduction()
                }
            }
        }
        .onChange(of: blurChanged) { _ in
            if blurChanged {
                blurChanged = false
            }
        }
        .onChange(of: vignetteChanged) { _ in
            if vignetteChanged {
                vignetteChanged = false
            }
        }
        .onChange(of: noiseChanged) { _ in
            if noiseChanged {
                noiseChanged = false
            }
        }
    }
}

struct EffectSlider: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let onChange: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                Spacer()
                Text(String(format: "%.1f", value))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Slider(value: $value, in: range)
                .accentColor(.blue)
                .onChange(of: value) { _ in onChange() }
        }
        .padding(.vertical, 8)
    }
}
