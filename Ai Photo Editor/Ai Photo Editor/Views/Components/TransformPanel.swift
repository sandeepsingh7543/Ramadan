import SwiftUI

struct TransformPanel: View {
    @ObservedObject var viewModel: PhotoEditorViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Transform")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.top)
            
            HStack(spacing: 12) {
                TransformButton(icon: "rotate.right", title: "Rotate") {
                    viewModel.rotateImage()
                }
                
                TransformButton(icon: "arrow.left.and.right", title: "Flip") {
                    viewModel.flipHorizontal()
                }
            }
            .padding(.horizontal)
        }
    }
}

struct TransformButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(10)
        }
    }
}
