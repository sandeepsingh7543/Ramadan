import SwiftUI

struct WatchlistView: View {
    @EnvironmentObject var movieManager: MovieManager
    @State private var selectedPriority = "All"
    @State private var showingAddToWatchlist = false
    
    let priorities = ["All", "High", "Medium", "Low"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            // Priority Filter
            priorityFilter
            
            // Content
            if movieManager.watchlist.isEmpty {
                emptyStateView
            } else {
                watchlistContent
            }
        }
        .sheet(isPresented: $showingAddToWatchlist) {
            AddToWatchlistView()
                .environmentObject(movieManager)
        }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text("Watchlist")
                    .font(.system(size: 32, weight: .ultraLight, design: .rounded))
                    .foregroundColor(.white)
                
                Text("\(movieManager.watchlist.count) movies to watch")
                    .font(.system(size: 14, weight: .light))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Button(action: { showingAddToWatchlist = true }) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.purple)
                    .background(Circle().fill(.white))
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    private var priorityFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(priorities, id: \.self) { priority in
                    Button(action: { selectedPriority = priority }) {
                        HStack(spacing: 6) {
                            priorityIcon(for: priority)
                            Text(priority)
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(selectedPriority == priority ? .black : .white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(selectedPriority == priority ? .white : .clear)
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
        .padding(.vertical, 15)
    }
    
    private var watchlistContent: some View {
        ScrollView {
            LazyVStack(spacing: 15) {
                ForEach(movieManager.watchlist) { movie in
                    WatchlistMovieCard(movie: movie)
                        .environmentObject(movieManager)
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "heart.slash")
                .font(.system(size: 60, weight: .ultraLight))
                .foregroundColor(.white.opacity(0.3))
            
            Text("Your watchlist is empty")
                .font(.system(size: 20, weight: .light))
                .foregroundColor(.white.opacity(0.7))
            
            Text("Add movies you want to watch later")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.5))
            
            Button(action: { showingAddToWatchlist = true }) {
                Text("Add Movies")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(.purple)
                    )
            }
            
            Spacer()
        }
    }
    
    private func priorityIcon(for priority: String) -> some View {
        Group {
            switch priority {
            case "All":
                Image(systemName: "list.bullet")
            case "High":
                Image(systemName: "exclamationmark.triangle.fill")
            case "Medium":
                Image(systemName: "minus.circle")
            case "Low":
                Image(systemName: "circle")
            default:
                Image(systemName: "list.bullet")
            }
        }
        .font(.system(size: 12))
    }
}

struct WatchlistMovieCard: View {
    let movie: CinemaMovie
    @EnvironmentObject var movieManager: MovieManager
    @State private var offset: CGFloat = 0
    @State private var showingDetail = false
    
    var body: some View {
        HStack(spacing: 15) {
            // Poster
            RoundedRectangle(cornerRadius: 12)
                .fill(movie.posterColor.color)
                .frame(width: 70, height: 100)
                .overlay(
                    Group {
                        if let posterImage = movie.posterImage {
                            Image(uiImage: posterImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 70, height: 100)
                                .clipped()
                                .cornerRadius(12)
                        } else {
                            Image(systemName: "film")
                                .font(.system(size: 20))
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
                    
                    Text(movie.durationFormatted)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Spacer()
                }
                
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.yellow)
                        
                        Text("\(movie.imdbRating, specifier: "%.1f")")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Button(action: { showingDetail = true }) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 16))
                            .foregroundColor(.blue)
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
        .offset(x: offset)
        .background(
            HStack {
                Spacer()
                
                // Remove from watchlist action
                Button(action: {
                    withAnimation {
                        movieManager.removeFromWatchlist(movie)
                    }
                }) {
                    VStack {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                        
                        Text("Remove")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                    }
                    .frame(width: 80)
                    .frame(maxHeight: .infinity)
                    .background(Color.red)
                }
                
                // Move to vault action
                Button(action: {
                    withAnimation {
                        movieManager.addMovie(movie)
                        movieManager.removeFromWatchlist(movie)
                    }
                }) {
                    VStack {
                        Image(systemName: "archivebox.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                        
                        Text("Watched")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                    }
                    .frame(width: 80)
                    .frame(maxHeight: .infinity)
                    .background(Color.green)
                }
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    if gesture.translation.width < 0 {
                        offset = gesture.translation.width
                    }
                }
                .onEnded { gesture in
                    withAnimation(.spring()) {
                        if gesture.translation.width < -100 {
                            offset = -160
                        } else {
                            offset = 0
                        }
                    }
                }
        )
        .sheet(isPresented: $showingDetail) {
            MovieDetailView(movie: movie)
                .environmentObject(movieManager)
        }
    }
}

struct AddToWatchlistView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var movieManager: MovieManager
    @State private var title = ""
    @State private var director = ""
    @State private var genre = "Action"
    @State private var releaseYear = 2024
    @State private var duration = 120
    @State private var synopsis = ""
    @State private var imdbRating = 7.0
    @State private var selectedColor = Color.blue
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    
    let genres = ["Action", "Comedy", "Drama", "Horror", "Sci-Fi", "Romance", "Thriller", "Animation"]
    let colors: [Color] = [.blue, .purple, .red, .orange, .green, .pink, .yellow, .cyan]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 10) {
                        Text("Add to Watchlist")
                            .font(.system(size: 28, weight: .light))
                            .foregroundColor(.white)
                        
                        Text("Movies you want to watch later")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.top, 20)
                    
                    // Form
                    VStack(spacing: 20) {
                        CustomTextFieldbasicInfo(title: "Movie Title", text: $title)
                        CustomTextFieldbasicInfo(title: "Director", text: $director)
                        
                        // Genre Picker
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Genre")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(genres, id: \.self) { genreOption in
                                        Button(action: { genre = genreOption }) {
                                            Text(genreOption)
                                                .font(.system(size: 14))
                                                .foregroundColor(genre == genreOption ? .black : .white)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 8)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .fill(genre == genreOption ? .white : .clear)
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
                        
                        // Image Selection
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Movie Poster")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                            
                            Button(action: { showingImagePicker = true }) {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedColor.opacity(0.3))
                                    .frame(height: 120)
                                    .overlay(
                                        Group {
                                            if let image = selectedImage {
                                                Image(uiImage: image)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(height: 120)
                                                    .clipped()
                                                    .cornerRadius(12)
                                            } else {
                                                VStack(spacing: 8) {
                                                    Image(systemName: "photo.badge.plus")
                                                        .font(.system(size: 24))
                                                        .foregroundColor(.white.opacity(0.7))
                                                    
                                                    Text("Add Poster")
                                                        .font(.system(size: 12))
                                                        .foregroundColor(.white.opacity(0.7))
                                                }
                                            }
                                        }
                                    )
                            }
                        }
                        
                        // Color Picker
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Poster Color")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                            
                            HStack(spacing: 15) {
                                ForEach(colors, id: \.self) { color in
                                    Button(action: { selectedColor = color }) {
                                        Circle()
                                            .fill(color)
                                            .frame(width: 30, height: 30)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.white, lineWidth: selectedColor == color ? 3 : 0)
                                            )
                                    }
                                }
                            }
                        }
                        
                        CustomTextFieldbasicInfo(title: "Synopsis", text: $synopsis, isMultiline: true)
                        
                        // Rating Slider
                        VStack(alignment: .leading, spacing: 10) {
                            Text("IMDb Rating: \(imdbRating, specifier: "%.1f")")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                            
                            Slider(value: $imdbRating, in: 1...10, step: 0.1)
                                .accentColor(.purple)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Add Button
                    Button(action: addToWatchlist) {
                        Text("Add to Watchlist")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(.purple)
                            )
                    }
                    .padding(.horizontal, 20)
                    .disabled(title.isEmpty || director.isEmpty)
                }
            }
            .background(
                Color.black
                    .ignoresSafeArea()
            )
            .navigationBarHidden(true)
            .overlay(
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 10),
                alignment: .top
            )
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
    }
    
    private func addToWatchlist() {
        let movie = CinemaMovie(
            title: title,
            director: director,
            genre: genre,
            releaseYear: releaseYear,
            duration: duration,
            synopsis: synopsis,
            imdbRating: imdbRating,
            posterColor: selectedColor,
            posterImage: selectedImage
        )
        
        movieManager.addToWatchlist(movie)
        dismiss()
    }
}

struct CustomTextFieldbasicInfo: View {
    let title: String
    @Binding var text: String
    var isMultiline: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
            
            if isMultiline {
                TextEditor(text: $text)
                    .frame(height: 80)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                    )
                    .foregroundColor(.white)
            } else {
                TextField("", text: $text)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(.white)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                    )
            }
        }
    }
}

#Preview {
    WatchlistView()
        .environmentObject(MovieManager())
}
