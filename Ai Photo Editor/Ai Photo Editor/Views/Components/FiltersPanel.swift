import SwiftUI

struct FiltersPanel: View {
    @ObservedObject var viewModel: PhotoEditorViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Filters")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.top)
            
            HStack(spacing: 12) {
                FilterCard(title: "B&W") {
                    viewModel.applyFilter(.blackAndWhite)
                }
                
                FilterCard(title: "Vintage") {
                    viewModel.applyFilter(.vintage)
                }
                
                FilterCard(title: "Cinematic") {
                    viewModel.applyFilter(.cinematic)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct FilterCard: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(10)
        }
    }
}
