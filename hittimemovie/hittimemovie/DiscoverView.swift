import SwiftUI

struct DiscoverView: View {
    @EnvironmentObject var movieManager: MovieManager
    @State private var selectedGenre = "All"
    @State private var showingAddMovie = false
    
    let genres = ["All", "Action", "Comedy", "Drama", "Horror", "Sci-Fi", "Romance", "Thriller"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Header
                headerView
                
                // Genre Filter
                genreFilter
                
                // Quick Add Section
                quickAddSection
                
                // Recent Additions
                recentAdditions
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
        .sheet(isPresented: $showingAddMovie) {
            AddMovieView()
                .environmentObject(movieManager)
        }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text("Discover")
                    .font(.system(size: 32, weight: .ultraLight, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Find your next favorite movie")
                    .font(.system(size: 14, weight: .light))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Button(action: { showingAddMovie = true }) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.purple)
                    .background(Circle().fill(.white))
            }
        }
    }
    
    private var genreFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(genres, id: \.self) { genre in
                    Button(action: { selectedGenre = genre }) {
                        Text(genre)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(selectedGenre == genre ? .black : .white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(selectedGenre == genre ? .white : .clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var quickAddSection: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Quick Add")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "bolt.fill")
                    .foregroundColor(.yellow)
            }
            
            Button(action: { showingAddMovie = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.purple)
                    
                    Text("Add a movie to your vault")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right")
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                        )
                )
            }
        }
    }
    
    private var recentAdditions: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Recently Added")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "clock.fill")
                    .foregroundColor(.blue)
            }
            
            if movieManager.myMovies.isEmpty {
                Text("No movies added yet")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.vertical, 20)
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 15) {
                    ForEach(movieManager.myMovies.prefix(3)) { movie in
                        RecentMovieCard(movie: movie)
                    }
                }
            }
        }
    }
}

struct TrendingMovie: Identifiable {
    let id = UUID()
    let title: String
    let genre: String
    let rating: Double
    let color: Color
}

struct TrendingMovieCard: View {
    let movie: TrendingMovie
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 12)
                .fill(movie.color.opacity(0.8))
                .aspectRatio(0.7, contentMode: .fit)
                
            
            VStack(alignment: .leading, spacing: 4) {
                Text(movie.title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                Text(movie.genre)
                    .font(.system(size: 9))
                    .foregroundColor(.white.opacity(0.7))
                
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 7))
                        .foregroundColor(.yellow)
                    
                    Text("\(movie.rating, specifier: "%.1f")")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.white)
                }
            }
        }
    }
}

struct RecentMovieCard: View {
    let movie: CinemaMovie
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 12)
                .fill(movie.posterColor.color)
                .aspectRatio(0.7, contentMode: .fit)
                .overlay(
                    Group {
                        if let posterImage = movie.posterImage {
                            Image(uiImage: posterImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .clipped()
                                .cornerRadius(12)
                        } else {
                            Image(systemName: "film")
                                .font(.system(size: 20))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                )
                .overlay(
                    VStack {
                        HStack {
                            Spacer()
                            if movie.isWatched {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.green)
                                    .background(Circle().fill(.black.opacity(0.6)))
                            }
                        }
                        Spacer()
                    }
                    .padding(8)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(movie.title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                Text(movie.director)
                    .font(.system(size: 9))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(1)
                
                Text(movie.genre)
                    .font(.system(size: 8))
                    .foregroundColor(.purple)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(.purple.opacity(0.2))
                    )
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

#Preview {
    DiscoverView()
        .environmentObject(MovieManager())
}
