import SwiftUI

struct TransformView: View {
    @ObservedObject var viewModel: PhotoEditorViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Transform")
                .font(.headline)
                .foregroundColor(colorScheme == .dark ? .white : .black)
            
            VStack(spacing: 12) {
                Text("Crop")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                
                HStack(spacing: 10) {
                    CropButton(label: "1:1", icon: "square") { viewModel.setCropRatio(1) }
                    CropButton(label: "4:3", icon: "rectangle") { viewModel.setCropRatio(4/3) }
                    CropButton(label: "16:9", icon: "rectangle.landscape") { viewModel.setCropRatio(16/9) }
                    CropButton(label: "Free", icon: "crop") { viewModel.setCropRatio(0) }
                }
            }
            
            Divider()
            
            HStack(spacing: 12) {
                ToolActionButton(icon: "rotate.right", label: "Rotate") {
                    viewModel.rotateImage()
                }
                
                ToolActionButton(icon: "arrow.left.and.right", label: "Flip H") {
                    viewModel.flipHorizontal()
                }
                
                ToolActionButton(icon: "arrow.up.and.down", label: "Flip V") {
                    viewModel.flipVertical()
                }
            }
        }
    }
}

struct CropButton: View {
    let label: String
    let icon: String
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                Text(label)
                    .font(.caption2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(8)
        }
    }
}

struct ToolActionButton: View {
    let icon: String
    let label: String
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title3)
                Text(label)
                    .font(.caption2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(8)
        }
    }
}
