import SwiftUI

struct AdjustPanel: View {
    @ObservedObject var viewModel: PhotoEditorViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Adjust")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.top)
            
            VStack(spacing: 12) {
                AdjustSlider(title: "Brightness", value: $viewModel.brightness, range: -0.5...0.5) {
                    viewModel.applyAdjustments()
                }
                
                AdjustSlider(title: "Contrast", value: $viewModel.contrast, range: 0.5...1.5) {
                    viewModel.applyAdjustments()
                }
                
                AdjustSlider(title: "Saturation", value: $viewModel.saturation, range: 0...2) {
                    viewModel.applyAdjustments()
                }
            }
            .padding(.horizontal)
            
            Button("Reset") {
                viewModel.resetAdjustments()
            }
            .foregroundColor(.white)
            .padding(.horizontal, 30)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.3))
            .cornerRadius(8)
        }
    }
}

struct AdjustSlider: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let onChange: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .foregroundColor(.white)
                    .font(.caption)
                Spacer()
                Text(String(format: "%.2f", value))
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            
            Slider(value: $value, in: range)
                .accentColor(.blue)
                .onChange(of: value) { _ in onChange() }
        }
    }
}
