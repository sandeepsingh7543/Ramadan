import SwiftUI

struct MyVaultView: View {
    @EnvironmentObject var movieManager: MovieManager
    @State private var searchText = ""
    @State private var selectedFilter = "All"
    @State private var showingGrid = true
    @State private var selectedMovie: CinemaMovie?
    
    let filters = ["All", "Watched", "Unwatched", "Favorites"]
    
    private var filteredMovies: [CinemaMovie] {
        var movies = movieManager.myMovies
        
        // Apply search filter
        if !searchText.isEmpty {
            movies = movies.filter { 
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.director.localizedCaseInsensitiveContains(searchText) ||
                $0.genre.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply status filter
        switch selectedFilter {
        case "Watched":
            movies = movies.filter { $0.isWatched }
        case "Unwatched":
            movies = movies.filter { !$0.isWatched }
        case "Favorites":
            movies = movies.filter { $0.personalRating >= 8.0 }
        default:
            break
        }
        
        return movies.sorted { $0.dateAdded > $1.dateAdded }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            // Search and Filter
            searchAndFilterView
            
            // Content
            if filteredMovies.isEmpty {
                emptyStateView
            } else {
                movieContentView
            }
        }
        .sheet(item: $selectedMovie) { movie in
            MovieDetailView(movie: movie)
                .environmentObject(movieManager)
        }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text("My Vault")
                    .font(.system(size: 32, weight: .ultraLight, design: .rounded))
                    .foregroundColor(.white)
                
                Text("\(movieManager.myMovies.count) movies collected")
                    .font(.system(size: 14, weight: .light))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Button(action: { showingGrid.toggle() }) {
                Image(systemName: showingGrid ? "list.bullet" : "square.grid.2x2")
                    .font(.system(size: 20))
                    .foregroundColor(.purple)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    private var searchAndFilterView: some View {
        VStack(spacing: 15) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.6))
                
                TextField("Search your vault...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(.white)
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            
            // Filter Buttons
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(filters, id: \.self) { filter in
                        Button(action: { selectedFilter = filter }) {
                            HStack(spacing: 6) {
                                filterIcon(for: filter)
                                Text(filter)
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(selectedFilter == filter ? .black : .white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(selectedFilter == filter ? .white : .clear)
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
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
    }
    
    private var movieContentView: some View {
        ScrollView {
            if showingGrid {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 15),
                    GridItem(.flexible(), spacing: 15)
                ], spacing: 20) {
                    ForEach(filteredMovies) { movie in
                        MovieGridCard(movie: movie) {
                            selectedMovie = movie
                        }
                    }
                }
                .padding(.horizontal, 20)
            } else {
                LazyVStack(spacing: 15) {
                    ForEach(filteredMovies) { movie in
                        MovieListCard(movie: movie) {
                            selectedMovie = movie
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "archivebox")
                .font(.system(size: 60, weight: .ultraLight))
                .foregroundColor(.white.opacity(0.3))
            
            Text("Your vault is empty")
                .font(.system(size: 20, weight: .light))
                .foregroundColor(.white.opacity(0.7))
            
            Text("Add some movies to get started")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.5))
            
            Spacer()
        }
    }
    
    private func filterIcon(for filter: String) -> some View {
        Group {
            switch filter {
            case "All":
                Image(systemName: "square.stack.3d.up")
            case "Watched":
                Image(systemName: "checkmark.circle")
            case "Unwatched":
                Image(systemName: "circle")
            case "Favorites":
                Image(systemName: "heart.fill")
            default:
                Image(systemName: "square.stack.3d.up")
            }
        }
        .font(.system(size: 12))
    }
}

struct MovieGridCard: View {
    let movie: CinemaMovie
    let onTap: () -> Void
    @EnvironmentObject var movieManager: MovieManager
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Poster
                RoundedRectangle(cornerRadius: 15)
                    .fill(movie.posterColor.color.opacity(0.8))
                    .frame(height: 200)
                    .overlay(
                        Group {
                            if let posterImage = movie.posterImage {
                                Image(uiImage: posterImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 200)
                                    .clipped()
                                    .cornerRadius(15)
                            } else {
                                VStack {
                                    HStack {
                                        Spacer()
                                        Button(action: {
                                            movieManager.toggleWatched(movie.id)
                                        }) {
                                            Image(systemName: movie.isWatched ? "checkmark.circle.fill" : "circle")
                                                .font(.system(size: 20))
                                                .foregroundColor(movie.isWatched ? .green : .white.opacity(0.7))
                                        }
                                    }
                                    .padding(12)
                                }
                            }
                        }
                    )
                    .overlay(
                        // Overlay for image posters
                        Group {
                            if movie.posterImage != nil {
                                VStack {
                                    HStack {
                                        Spacer()
                                        Button(action: {
                                            movieManager.toggleWatched(movie.id)
                                        }) {
                                            Image(systemName: movie.isWatched ? "checkmark.circle.fill" : "circle")
                                                .font(.system(size: 20))
                                                .foregroundColor(movie.isWatched ? .green : .white)
                                                .background(Circle().fill(.black.opacity(0.6)))
                                        }
                                    }
                                    .padding(12)
                                    
                                    Spacer()
                                }
                            }
                        }
                    )
                
                // Movie Info
                VStack(alignment: .leading, spacing: 6) {
                    Text(movie.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                    
                    Text(movie.director)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(1)
                    
                    HStack {
                        Text(movie.genre)
                            .font(.system(size: 10))
                            .foregroundColor(.purple)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.purple.opacity(0.2))
                            )
                        
                        Spacer()
                        
                        if movie.personalRating > 0 {
                            HStack(spacing: 2) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 8))
                                    .foregroundColor(.yellow)
                                
                                Text("\(movie.personalRating, specifier: "%.1f")")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MovieListCard: View {
    let movie: CinemaMovie
    let onTap: () -> Void
    @EnvironmentObject var movieManager: MovieManager
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 15) {
                // Poster
                RoundedRectangle(cornerRadius: 12)
                    .fill(movie.posterColor.color)
                    .frame(width: 80, height: 110)
                    .overlay(
                        Group {
                            if let posterImage = movie.posterImage {
                                Image(uiImage: posterImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 80, height: 110)
                                    .clipped()
                                    .cornerRadius(12)
                            } else {
                                Image(systemName: "film")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                    )
                
                // Movie Info
                VStack(alignment: .leading, spacing: 8) {
                    Text(movie.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                    
                    Text(movie.director)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                    
                    HStack {
                        Text(movie.genre)
                            .font(.system(size: 12))
                            .foregroundColor(.purple)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.purple.opacity(0.2))
                            )
                        
                        Text("\(movie.releaseYear)")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                        
                        Spacer()
                    }
                    
                    HStack {
                        if movie.personalRating > 0 {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.yellow)
                                
                                Text("\(movie.personalRating, specifier: "%.1f")")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            movieManager.toggleWatched(movie.id)
                        }) {
                            Image(systemName: movie.isWatched ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 20))
                                .foregroundColor(movie.isWatched ? .green : .white.opacity(0.7))
                        }
                    }
                }
                
                Spacer()
            }
            .padding(15)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    MyVaultView()
        .environmentObject(MovieManager())
}
