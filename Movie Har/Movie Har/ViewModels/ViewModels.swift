import SwiftUI
import CoreData

@MainActor
class MovieViewModel: ObservableObject {
    private let context: NSManagedObjectContext
    @Published var movies: [MovieEntry] = []
    
    init(context: NSManagedObjectContext) {
        self.context = context
        fetchMovies()
    }
    
    func fetchMovies() {
        let request = NSFetchRequest<MovieEntry>(entityName: "MovieEntry")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MovieEntry.createdAt, ascending: false)]
        movies = (try? context.fetch(request)) ?? []
    }
    
    func addMovie(title: String, description: String, posterImage: Data?, castNotes: String, rating: Double) {
        let movie = MovieEntry(context: context)
        movie.id = UUID()
        movie.title = title
        movie.movieDescription = description
        movie.posterImageData = posterImage
        movie.castNotes = castNotes
        movie.rating = rating
        movie.createdAt = Date()
        save()
    }
    
    func deleteMovie(_ movie: MovieEntry) {
        context.delete(movie)
        save()
    }
    
    private func save() {
        try? context.save()
        fetchMovies()
    }
}

@MainActor
class SceneViewModel: ObservableObject {
    private let context: NSManagedObjectContext
    @Published var scenes: [SceneEntry] = []
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchScenes(for movie: MovieEntry) {
        let request = NSFetchRequest<SceneEntry>(entityName: "SceneEntry")
        request.predicate = NSPredicate(format: "movie == %@", movie)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \SceneEntry.sequence, ascending: true)]
        scenes = (try? context.fetch(request)) ?? []
    }
    
    func addScene(to movie: MovieEntry, title: String, emotion: String, dialogue: String, notes: String) {
        let scene = SceneEntry(context: context)
        scene.id = UUID()
        scene.title = title
        scene.emotion = emotion
        scene.dialogue = dialogue
        scene.notes = notes
        scene.sequence = Int16((movie.scenes?.count ?? 0) + 1)
        scene.createdAt = Date()
        scene.movie = movie
        try? context.save()
        fetchScenes(for: movie)
    }
}

@MainActor
class FilmIdeaViewModel: ObservableObject {
    private let context: NSManagedObjectContext
    @Published var ideas: [FilmIdea] = []
    
    init(context: NSManagedObjectContext) {
        self.context = context
        fetchIdeas()
    }
    
    func fetchIdeas() {
        let request = NSFetchRequest<FilmIdea>(entityName: "FilmIdea")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FilmIdea.createdAt, ascending: false)]
        ideas = (try? context.fetch(request)) ?? []
    }
    
    func saveIdea(title: String, genre: String, story: String, characters: String, endings: String) {
        let idea = FilmIdea(context: context)
        idea.id = UUID()
        idea.title = title
        idea.genre = genre
        idea.storyIdea = story
        idea.characters = characters
        idea.endings = endings
        idea.createdAt = Date()
        try? context.save()
        fetchIdeas()
    }
    
    func deleteIdea(_ idea: FilmIdea) {
        context.delete(idea)
        try? context.save()
        fetchIdeas()
    }
}
