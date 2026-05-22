import SwiftUI

struct EditorView: View {
    @StateObject private var viewModel: PhotoEditorViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedCategory: ToolCategory = .ai
    @State private var showBeforeAfter = false
    @State private var showSaveProgress = false
    
    init(image: UIImage) {
        _viewModel = StateObject(wrappedValue: PhotoEditorViewModel(image: image))
    }
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            VStack(spacing: 0) {
                topBar
                
                ZStack {
                    if showBeforeAfter {
                        Image(uiImage: viewModel.originalImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .transition(.opacity)
                    } else if let currentImage = viewModel.currentImage {
                        Image(uiImage: currentImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .transition(.opacity)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGray6))
                .overlay(alignment: .topTrailing) {
                    beforeAfterButton
                }
                
                toolCategoryBar
                
                toolOptionsPanel
                    .frame(height: 280)
                    .background(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 8, y: -4)
            }
            
            if viewModel.isLoading {
                loadingOverlay
            }
            
            if showSaveProgress {
                saveProgressOverlay
            }
        }
        .navigationBarHidden(true)
        .alert(viewModel.alertMessage, isPresented: $viewModel.showAlert) {
            Button("OK", role: .cancel) {}
        }
    }
    
    private var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button {
                    viewModel.undo()
                } label: {
                    Image(systemName: "arrow.uturn.backward.circle.fill")
                        .font(.title2)
                        .foregroundColor(viewModel.canUndo ? .blue : .gray)
                }
                .disabled(!viewModel.canUndo)
                
                Button {
                    viewModel.redo()
                } label: {
                    Image(systemName: "arrow.uturn.forward.circle.fill")
                        .font(.title2)
                        .foregroundColor(viewModel.canRedo ? .blue : .gray)
                }
                .disabled(!viewModel.canRedo)
                
                Button {
                    viewModel.resetAdjustments()
                    viewModel.currentImage = viewModel.originalImage
                } label: {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private var beforeAfterButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.3)) {
                showBeforeAfter.toggle()
            }
            hapticFeedback()
        } label: {
            VStack(spacing: 4) {
                Image(systemName: showBeforeAfter ? "photo.fill" : "photo")
                    .font(.caption)
                Text(showBeforeAfter ? "Before" : "After")
                    .font(.caption2)
            }
            .foregroundColor(.white)
            .padding(8)
            .background(Color.black.opacity(0.6))
            .cornerRadius(8)
        }
        .padding()
    }
    
    private var toolCategoryBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(ToolCategory.allCases, id: \.self) { category in
                    CategoryButton(
                        category: category,
                        isSelected: selectedCategory == category
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedCategory = category
                        }
                        hapticFeedback()
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }
    
    @ViewBuilder
    private var toolOptionsPanel: some View {
        ScrollView {
            VStack(spacing: 16) {
                switch selectedCategory {
                case .ai:
                    AIToolsPanel(viewModel: viewModel)
                case .filters:
                    FiltersGridView(viewModel: viewModel)
                case .adjustments:
                    AdjustmentsView(viewModel: viewModel)
                case .transform:
                    TransformView(viewModel: viewModel)
                case .effects:
                    EffectsView(viewModel: viewModel)
                case .utility:
                    UtilityView(viewModel: viewModel, showSaveProgress: $showSaveProgress)
                }
            }
            .padding()
        }
    }
    
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            VStack(spacing: 12) {
                ProgressView()
                    .scaleEffect(1.2)
                Text("Processing...")
                    .font(.caption)
                    .foregroundColor(.white)
            }
            .padding(24)
            .background(Color.black.opacity(0.8))
            .cornerRadius(12)
        }
    }
    
    private var saveProgressOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            VStack(spacing: 12) {
                ProgressView(value: 0.7)
                    .tint(.blue)
                Text("Saving photo...")
                    .font(.caption)
                    .foregroundColor(.white)
            }
            .padding(24)
            .background(Color.black.opacity(0.8))
            .cornerRadius(12)
        }
    }
    
    private func hapticFeedback() {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
}

struct CategoryButton: View {
    let category: ToolCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: category.icon)
                    .font(.title3)
                Text(category.label)
                    .font(.caption2)
            }
            .foregroundColor(isSelected ? .white : .gray)
            .frame(minWidth: 60)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(isSelected ? Color.blue : Color(.systemGray5))
            .cornerRadius(10)
        }
    }
}

enum ToolCategory: CaseIterable {
    case ai, filters, adjustments, transform, effects, utility
    
    var label: String {
        switch self {
        case .ai: return "AI"
        case .filters: return "Filters"
        case .adjustments: return "Adjust"
        case .transform: return "Transform"
        case .effects: return "Effects"
        case .utility: return "Tools"
        }
    }
    
    var icon: String {
        switch self {
        case .ai: return "wand.and.stars"
        case .filters: return "camera.filters"
        case .adjustments: return "slider.horizontal.3"
        case .transform: return "crop.rotate"
        case .effects: return "sparkles"
        case .utility: return "wrench.and.screwdriver"
        }
    }
}
