import SwiftUI
import PhotosUI

struct MovieJournalView: View {
    @Environment(\.managedObjectContext) private var context
    @StateObject private var viewModel: MovieViewModel
    @State private var showAddMovie = false
    
    init() {
        let context = PersistenceController.shared.container.viewContext
        _viewModel = StateObject(wrappedValue: MovieViewModel(context: context))
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.movies.isEmpty {
                    emptyState
                } else {
                    movieList
                }
            }
            .background(Color.black)
            .navigationTitle("My Movie Journal")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddMovie = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(.white)
                    }
                }
            }
            .sheet(isPresented: $showAddMovie) {
                AddMovieView(viewModel: viewModel)
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "film")
                .font(.system(size: 60))
                .foregroundStyle(.gray)
            Text("Start Your Movie Journal")
                .font(.title2.bold())
                .foregroundStyle(.white)
            Text("Add your favorite films and create personal memories")
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private var movieList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.movies, id: \.id) { movie in
                    NavigationLink(destination: MovieDetailView(movie: movie)) {
                        MovieCard(movie: movie)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .background(Color.black)
    }
}

struct MovieCard: View {
    let movie: MovieEntry
    
    var body: some View {
        HStack(spacing: 12) {
            if let imageData = movie.posterImageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.gray.opacity(0.3))
                    .frame(width: 80, height: 120)
                    .overlay {
                        Image(systemName: "photo")
                            .foregroundStyle(.gray)
                    }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(movie.title ?? "")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .lineLimit(2)
                
                if let description = movie.movieDescription, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                        .lineLimit(2)
                }
                
                HStack(spacing: 4) {
                    ForEach(0..<5) { index in
                        Image(systemName: index < Int(movie.rating) ? "star.fill" : "star")
                            .font(.caption)
                            .foregroundStyle(.yellow)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct AddMovieView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: MovieViewModel
    
    @State private var title = ""
    @State private var movieDescription = ""
    @State private var castNotes = ""
    @State private var rating = 3.0
    @State private var selectedImage: PhotosPickerItem?
    @State private var imageData: Data?
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Movie Title", text: $title)
                        .foregroundStyle(.white)
                } header: {
                    Text("Title")
                }
                
                Section {
                    TextField("Description", text: $movieDescription, axis: .vertical)
                        .lineLimit(3...6)
                        .foregroundStyle(.white)
                } header: {
                    Text("Description")
                }
                
                Section {
                    PhotosPicker(selection: $selectedImage, matching: .images) {
                        HStack {
                            if let imageData, let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 150)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            } else {
                                Label("Select Poster from Photos", systemImage: "photo.on.rectangle")
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                } header: {
                    Text("Poster (from your photos)")
                } footer: {
                    Text("Choose an image from your photo library")
                }
                
                Section {
                    TextField("Characters & Cast", text: $castNotes, axis: .vertical)
                        .lineLimit(3...6)
                        .foregroundStyle(.white)
                } header: {
                    Text("Characters & Cast Notes")
                }
                
                Section {
                    HStack {
                        Text("Rating")
                            .foregroundStyle(.white)
                        Spacer()
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: star <= Int(rating) ? "star.fill" : "star")
                                .foregroundStyle(.yellow)
                                .onTapGesture {
                                    rating = Double(star)
                                }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.black)
            .navigationTitle("Add Movie")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.white)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.addMovie(title: title, description: movieDescription, posterImage: imageData, castNotes: castNotes, rating: rating)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                    .foregroundStyle(title.isEmpty ? .gray : .blue)
                }
            }
            .onChange(of: selectedImage) { _, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        imageData = data
                    }
                }
            }
        }
    }
}
