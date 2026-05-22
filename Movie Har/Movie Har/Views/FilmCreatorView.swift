import SwiftUI

struct FilmCreatorView: View {
    @Environment(\.managedObjectContext) private var context
    @StateObject private var viewModel: FilmIdeaViewModel
    @State private var showGenerator = false
    
    init() {
        let context = PersistenceController.shared.container.viewContext
        _viewModel = StateObject(wrappedValue: FilmIdeaViewModel(context: context))
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.ideas.isEmpty {
                    emptyState
                } else {
                    ideaList
                }
            }
            .background(Color.black)
            .navigationTitle("Film Creator")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showGenerator = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(.white)
                    }
                }
            }
            .sheet(isPresented: $showGenerator) {
                IdeaGeneratorView(viewModel: viewModel)
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 60))
                .foregroundStyle(.yellow)
            Text("Create Your Film Ideas")
                .font(.title2.bold())
                .foregroundStyle(.white)
            Text("Generate original stories, characters, and plot twists")
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private var ideaList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.ideas, id: \.id) { idea in
                    NavigationLink(destination: IdeaDetailView(idea: idea)) {
                        IdeaCard(idea: idea)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .background(Color.black)
    }
}

struct IdeaCard: View {
    let idea: FilmIdea
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(idea.genre ?? "")
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.blue.opacity(0.4))
                    .clipShape(Capsule())
                Spacer()
            }
            
            Text(idea.title ?? "")
                .font(.headline)
                .foregroundStyle(.white)
            
            if let story = idea.storyIdea, !story.isEmpty {
                Text(story)
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                    .lineLimit(3)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct IdeaGeneratorView: View {
    @ObservedObject var viewModel: FilmIdeaViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var selectedGenres: Set<String> = []
    @State private var storyIdea = ""
    @State private var characters = ""
    @State private var endings = ""
    @State private var showingGenerator = false
    
    let genres = ["Drama", "Thriller", "Romance", "Comedy", "Mystery", "Sci-Fi", "Horror", "Adventure"]
    
    var genreString: String {
        selectedGenres.sorted().joined(separator: " + ")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Title") {
                    TextField("Film Title", text: $title)
                        .foregroundStyle(.white)
                }
                
                Section("Genre Mix") {
                    FlowLayout(spacing: 8) {
                        ForEach(genres, id: \.self) { genre in
                            GenreChip(genre: genre, isSelected: selectedGenres.contains(genre)) {
                                if selectedGenres.contains(genre) {
                                    selectedGenres.remove(genre)
                                } else {
                                    selectedGenres.insert(genre)
                                }
                            }
                        }
                    }
                }
                
                Section {
                    Button("Generate Story Idea") {
                        generateStory()
                    }
                    .foregroundStyle(.blue)
                    .frame(maxWidth: .infinity)
                } footer: {
                    Text("Creates a unique story concept based on your genre selection")
                }
                
                Section("Story Concept") {
                    TextField("Story idea", text: $storyIdea, axis: .vertical)
                        .lineLimit(4...8)
                        .foregroundStyle(.white)
                }
                
                Section("Characters") {
                    TextField("Main characters", text: $characters, axis: .vertical)
                        .lineLimit(3...6)
                        .foregroundStyle(.white)
                    Button("Generate Characters") {
                        generateCharacters()
                    }
                    .foregroundStyle(.blue)
                }
                
                Section("Multiple Endings") {
                    TextField("Ending variations", text: $endings, axis: .vertical)
                        .lineLimit(3...6)
                        .foregroundStyle(.white)
                    Button("Generate Endings") {
                        generateEndings()
                    }
                    .foregroundStyle(.blue)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.black)
            .navigationTitle("New Film Idea")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.white)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.saveIdea(title: title, genre: genreString, story: storyIdea, characters: characters, endings: endings)
                        dismiss()
                    }
                    .disabled(title.isEmpty || selectedGenres.isEmpty)
                    .foregroundStyle(title.isEmpty || selectedGenres.isEmpty ? .gray : .blue)
                }
            }
        }
    }
    
    private func generateStory() {
        let templates = [
            "A person discovers an unexpected truth that changes everything they believed about their life.",
            "Two strangers meet under unusual circumstances and must work together to solve a mystery.",
            "Someone receives a mysterious message that leads them on an unexpected journey.",
            "A character must choose between following their dreams or fulfilling family expectations.",
            "An ordinary day takes an extraordinary turn when something impossible happens."
        ]
        storyIdea = templates.randomElement() ?? ""
    }
    
    private func generateCharacters() {
        let names = ["Alex", "Jordan", "Morgan", "Casey", "Riley", "Taylor", "Sam", "Drew"]
        let traits = ["determined", "mysterious", "charismatic", "conflicted", "brave", "clever"]
        let roles = ["protagonist", "mentor", "rival", "ally"]
        
        let char1 = "\(names.randomElement()!) - \(traits.randomElement()!) \(roles.randomElement()!)"
        let char2 = "\(names.randomElement()!) - \(traits.randomElement()!) \(roles.randomElement()!)"
        characters = "\(char1)\n\(char2)"
    }
    
    private func generateEndings() {
        endings = """
        Ending 1: Resolution with hope
        Ending 2: Bittersweet conclusion
        Ending 3: Unexpected twist
        """
    }
}

struct GenreChip: View {
    let genre: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(genre)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color.white.opacity(0.2))
                .foregroundStyle(.white)
                .clipShape(Capsule())
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }
                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}

struct IdeaDetailView: View {
    let idea: FilmIdea
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text(idea.genre ?? "")
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.blue.opacity(0.4))
                        .clipShape(Capsule())
                    Spacer()
                }
                
                if let story = idea.storyIdea, !story.isEmpty {
                    SectionView(title: "Story Concept", content: story)
                }
                
                if let characters = idea.characters, !characters.isEmpty {
                    SectionView(title: "Characters", content: characters)
                }
                
                if let endings = idea.endings, !endings.isEmpty {
                    SectionView(title: "Endings", content: endings)
                }
            }
            .padding()
        }
        .background(Color.black)
        .navigationTitle(idea.title ?? "")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SectionView: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
            Text(content)
                .foregroundStyle(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
