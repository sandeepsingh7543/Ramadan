import SwiftUI
import Foundation

class MovieManager: ObservableObject {
    @Published var myMovies: [CinemaMovie] = []
    @Published var watchlist: [CinemaMovie] = []
    @Published var reviews: [MovieReview] = []
    @Published var tickets: [MovieTicket] = []
    @Published var favoriteGenres: [String] = []
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    init() {
        loadData()
        setupSampleData()
    }
    
    func addMovie(_ movie: CinemaMovie) {
        myMovies.append(movie)
        saveData()
    }
    
    func addToWatchlist(_ movie: CinemaMovie) {
        if !watchlist.contains(where: { $0.id == movie.id }) {
            watchlist.append(movie)
            saveData()
        }
    }
    
    func removeFromWatchlist(_ movie: CinemaMovie) {
        watchlist.removeAll { $0.id == movie.id }
        saveData()
    }
    
    func addReview(_ review: MovieReview) {
        reviews.append(review)
        saveData()
    }
    
    func addTicket(_ ticket: MovieTicket) {
        tickets.append(ticket)
        saveData()
    }
    
    func updateMovieRating(_ movieId: UUID, rating: Double) {
        if let index = myMovies.firstIndex(where: { $0.id == movieId }) {
            myMovies[index].personalRating = rating
            saveData()
        }
    }
    
    func toggleWatched(_ movieId: UUID) {
        if let index = myMovies.firstIndex(where: { $0.id == movieId }) {
            myMovies[index].isWatched.toggle()
            saveData()
        }
    }
    
    private func saveData() {
        if let encoded = try? encoder.encode(myMovies) {
            UserDefaults.standard.set(encoded, forKey: "myMovies")
        }
        if let encoded = try? encoder.encode(watchlist) {
            UserDefaults.standard.set(encoded, forKey: "watchlist")
        }
        if let encoded = try? encoder.encode(reviews) {
            UserDefaults.standard.set(encoded, forKey: "reviews")
        }
        if let encoded = try? encoder.encode(tickets) {
            UserDefaults.standard.set(encoded, forKey: "tickets")
        }
        if let encoded = try? encoder.encode(favoriteGenres) {
            UserDefaults.standard.set(encoded, forKey: "favoriteGenres")
        }
    }
    
    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: "myMovies"),
           let decoded = try? decoder.decode([CinemaMovie].self, from: data) {
            myMovies = decoded
        }
        if let data = UserDefaults.standard.data(forKey: "watchlist"),
           let decoded = try? decoder.decode([CinemaMovie].self, from: data) {
            watchlist = decoded
        }
        if let data = UserDefaults.standard.data(forKey: "reviews"),
           let decoded = try? decoder.decode([MovieReview].self, from: data) {
            reviews = decoded
        }
        if let data = UserDefaults.standard.data(forKey: "tickets"),
           let decoded = try? decoder.decode([MovieTicket].self, from: data) {
            tickets = decoded
        }
        if let data = UserDefaults.standard.data(forKey: "favoriteGenres"),
           let decoded = try? decoder.decode([String].self, from: data) {
            favoriteGenres = decoded
        }
    }
    
    private func setupSampleData() {
        if myMovies.isEmpty {
            let sampleMovies = [
                CinemaMovie(
                    title: "Inception",
                    director: "Christopher Nolan",
                    genre: "Sci-Fi",
                    releaseYear: 2010,
                    duration: 148,
                    synopsis: "A thief who steals corporate secrets through dream-sharing technology is given the inverse task of planting an idea into the mind of a C.E.O.",
                    imdbRating: 8.8,
                    personalRating: 9.0,
                    posterColor: .blue,
                    isWatched: true
                ),
                CinemaMovie(
                    title: "The Dark Knight",
                    director: "Christopher Nolan",
                    genre: "Action",
                    releaseYear: 2008,
                    duration: 152,
                    synopsis: "When the menace known as the Joker wreaks havoc and chaos on the people of Gotham, Batman must accept one of the greatest psychological and physical tests.",
                    imdbRating: 9.0,
                    personalRating: 9.5,
                    posterColor: .orange,
                    isWatched: true
                )
            ]
            myMovies = sampleMovies
            saveData()
        }
    }
}

struct CinemaMovie: Identifiable, Codable, Hashable {
    let id = UUID()
    let title: String
    let director: String
    let genre: String
    let releaseYear: Int
    let duration: Int // in minutes
    let synopsis: String
    let imdbRating: Double
    var personalRating: Double
    let posterColor: CodableColor
    var isWatched: Bool
    let dateAdded: Date
    var notes: String
    let posterImageData: Data?
    
    init(title: String, director: String, genre: String, releaseYear: Int, duration: Int, synopsis: String, imdbRating: Double, personalRating: Double = 0.0, posterColor: Color, isWatched: Bool = false, notes: String = "", posterImage: UIImage? = nil) {
        self.title = title
        self.director = director
        self.genre = genre
        self.releaseYear = releaseYear
        self.duration = duration
        self.synopsis = synopsis
        self.imdbRating = imdbRating
        self.personalRating = personalRating
        self.posterColor = CodableColor(color: posterColor)
        self.isWatched = isWatched
        self.dateAdded = Date()
        self.notes = notes
        self.posterImageData = posterImage?.jpegData(compressionQuality: 0.8)
    }
    
    var posterImage: UIImage? {
        guard let data = posterImageData else { return nil }
        return UIImage(data: data)
    }
    
    var durationFormatted: String {
        let hours = duration / 60
        let minutes = duration % 60
        return "\(hours)h \(minutes)m"
    }
}

struct MovieReview: Identifiable, Codable {
    let id = UUID()
    let movieId: UUID
    let rating: Double
    let reviewText: String
    let dateCreated: Date
    
    init(movieId: UUID, rating: Double, reviewText: String) {
        self.movieId = movieId
        self.rating = rating
        self.reviewText = reviewText
        self.dateCreated = Date()
    }
}

struct MovieTicket: Identifiable, Codable {
    let id = UUID()
    let movieId: UUID
    let movieTitle: String
    let theater: String
    let showDate: Date
    let showTime: String
    let seatNumber: String
    let price: Double
    let bookingDate: Date
    
    init(movieId: UUID, movieTitle: String, theater: String, showDate: Date, showTime: String, seatNumber: String, price: Double) {
        self.movieId = movieId
        self.movieTitle = movieTitle
        self.theater = theater
        self.showDate = showDate
        self.showTime = showTime
        self.seatNumber = seatNumber
        self.price = price
        self.bookingDate = Date()
    }
}

struct CodableColor: Codable, Hashable {
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double
    
    init(color: Color) {
        let uiColor = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        self.red = Double(r)
        self.green = Double(g)
        self.blue = Double(b)
        self.alpha = Double(a)
    }
    
    var color: Color {
        Color(red: red, green: green, blue: blue, opacity: alpha)
    }
}
