import SwiftUI

struct AdjustmentsView: View {
    @ObservedObject var viewModel: PhotoEditorViewModel
    @State private var hasChanges = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Adjustments")
                .font(.headline)
                .foregroundColor(colorScheme == .dark ? .white : .black)
            
            AdjustmentSlider(title: "Brightness", value: $viewModel.brightness, range: -1...1) {
                hasChanges = true
                viewModel.applyAdjustments()
            }
            
            AdjustmentSlider(title: "Contrast", value: $viewModel.contrast, range: 0.5...1.5) {
                hasChanges = true
                viewModel.applyAdjustments()
            }
            
            AdjustmentSlider(title: "Saturation", value: $viewModel.saturation, range: 0...2) {
                hasChanges = true
                viewModel.applyAdjustments()
            }
            
            AdjustmentSlider(title: "Exposure", value: $viewModel.exposure, range: -1...1) {
                hasChanges = true
                viewModel.applyAdjustments()
            }
            
            AdjustmentSlider(title: "Sharpness", value: $viewModel.sharpness, range: 0...2) {
                hasChanges = true
                viewModel.applyAdjustments()
            }
            
            AdjustmentSlider(title: "Highlights", value: $viewModel.highlights, range: -1...1) {
                hasChanges = true
                viewModel.applyAdjustments()
            }
            
            AdjustmentSlider(title: "Shadows", value: $viewModel.shadows, range: -1...1) {
                hasChanges = true
                viewModel.applyAdjustments()
            }
        }
        .onChange(of: hasChanges) { _ in
            if hasChanges {
                viewModel.saveToUndo()
                hasChanges = false
            }
        }
    }
}

struct AdjustmentSlider: View {
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
                Text(String(format: "%.2f", value))
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
