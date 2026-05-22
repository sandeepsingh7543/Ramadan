import SwiftUI

struct UtilityView: View {
    @ObservedObject var viewModel: PhotoEditorViewModel
    @Binding var showSaveProgress: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Tools")
                .font(.headline)
                .foregroundColor(colorScheme == .dark ? .white : .black)
            
            HStack(spacing: 12) {
                Button {
                    viewModel.resetAdjustments()
                    viewModel.currentImage = viewModel.originalImage
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: "arrow.clockwise")
                            .font(.title3)
                        Text("Reset")
                            .font(.caption2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .foregroundColor(.white)
                    .background(Color.gray)
                    .cornerRadius(8)
                }
                
                Button {
                    showSaveProgress = true
                    viewModel.saveToLibrary()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        showSaveProgress = false
                    }
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.down")
                            .font(.title3)
                        Text("Save")
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
    }
}
