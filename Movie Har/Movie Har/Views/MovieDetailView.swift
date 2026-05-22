import SwiftUI

struct MovieDetailView: View {
    let movie: MovieEntry
    @Environment(\.managedObjectContext) private var context
    @StateObject private var sceneViewModel: SceneViewModel
    @State private var showAddScene = false
    
    init(movie: MovieEntry) {
        self.movie = movie
        let context = PersistenceController.shared.container.viewContext
        _sceneViewModel = StateObject(wrappedValue: SceneViewModel(context: context))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                
                if let description = movie.movieDescription, !description.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text(description)
                            .foregroundStyle(.gray)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                if let cast = movie.castNotes, !cast.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Characters & Cast")
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text(cast)
                            .foregroundStyle(.gray)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                scenesSection
            }
            .padding()
        }
        .background(Color.black)
        .navigationTitle(movie.title ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            sceneViewModel.fetchScenes(for: movie)
        }
    }
    
    private var headerSection: some View {
        HStack(alignment: .top, spacing: 16) {
            if let imageData = movie.posterImageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 4) {
                    ForEach(0..<5) { index in
                        Image(systemName: index < Int(movie.rating) ? "star.fill" : "star")
                            .foregroundStyle(.yellow)
                    }
                }
                
                Text("Added \(movie.createdAt?.formatted(date: .abbreviated, time: .omitted) ?? "")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private var scenesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Scene Memories")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                Button {
                    showAddScene = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.blue)
                }
            }
            
            if sceneViewModel.scenes.isEmpty {
                Text("No scenes added yet. Tap + to add your favorite moments.")
                    .foregroundStyle(.gray)
                    .padding()
            } else {
                ForEach(sceneViewModel.scenes, id: \.id) { scene in
                    SceneCard(scene: scene)
                }
            }
        }
        .sheet(isPresented: $showAddScene) {
            AddSceneView(movie: movie, viewModel: sceneViewModel)
        }
    }
}

struct SceneCard: View {
    let scene: SceneEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Chapter \(scene.sequence)")
                    .font(.caption.bold())
                    .foregroundStyle(.gray)
                Spacer()
                Text(scene.emotion ?? "")
                    .font(.title2)
            }
            
            Text(scene.title ?? "")
                .font(.headline)
                .foregroundStyle(.white)
            
            if let dialogue = scene.dialogue, !dialogue.isEmpty {
                Text(dialogue)
                    .font(.subheadline)
                    .italic()
                    .foregroundStyle(.gray)
            }
            
            if let notes = scene.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct AddSceneView: View {
    let movie: MovieEntry
    @ObservedObject var viewModel: SceneViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var emotion = "🔥"
    @State private var dialogue = ""
    @State private var notes = ""
    
    let emotions = ["🔥", "😢", "😍", "😱", "😂", "🤔", "😌", "😡"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Scene Title") {
                    TextField("Title", text: $title)
                        .foregroundStyle(.white)
                }
                
                Section("Emotion") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(emotions, id: \.self) { emoji in
                                Text(emoji)
                                    .font(.system(size: 40))
                                    .padding(8)
                                    .background(emotion == emoji ? Color.blue.opacity(0.4) : Color.clear)
                                    .clipShape(Circle())
                                    .onTapGesture {
                                        emotion = emoji
                                    }
                            }
                        }
                    }
                }
                
                Section("Dialogue") {
                    TextField("Memorable dialogue", text: $dialogue, axis: .vertical)
                        .lineLimit(3...6)
                        .foregroundStyle(.white)
                }
                
                Section("Why This Scene Matters") {
                    TextField("Your notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                        .foregroundStyle(.white)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.black)
            .navigationTitle("Add Scene")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.white)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.addScene(to: movie, title: title, emotion: emotion, dialogue: dialogue, notes: notes)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                    .foregroundStyle(title.isEmpty ? .gray : .blue)
                }
            }
        }
    }
}
