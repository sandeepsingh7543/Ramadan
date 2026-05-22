import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var movieManager: MovieManager
    @State private var showingExportAlert = false
    @State private var showingClearAlert = false
    @State private var showingMovieStats = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Header
                headerView
                
                // Stats Cards
                statsSection
                
                // Recent Activity
                recentActivitySection
                
                // Favorite Genres
                favoriteGenresSection
                
                // Settings
                settingsSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
        .alert("Export Data", isPresented: $showingExportAlert) {
            Button("Export") { exportData() }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Export your movie collection as JSON file?")
        }
        .alert("Clear All Data", isPresented: $showingClearAlert) {
            Button("Clear", role: .destructive) { clearAllData() }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will permanently delete all your movies, watchlist, and reviews. This action cannot be undone.")
        }
        .sheet(isPresented: $showingMovieStats) {
            MovieAnalyticsView()
                .environmentObject(movieManager)
        }
    }
    
    private func exportData() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        let exportData = ExportData(
            movies: movieManager.myMovies,
            watchlist: movieManager.watchlist,
            reviews: movieManager.reviews
        )
        
        if let data = try? encoder.encode(exportData),
           let jsonString = String(data: data, encoding: .utf8) {
            
            let activityVC = UIActivityViewController(
                activityItems: [jsonString],
                applicationActivities: nil
            )
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController?.present(activityVC, animated: true)
            }
        }
    }
    
    private func clearAllData() {
        movieManager.myMovies.removeAll()
        movieManager.watchlist.removeAll()
        movieManager.reviews.removeAll()
        movieManager.favoriteGenres.removeAll()
        
        UserDefaults.standard.removeObject(forKey: "myMovies")
        UserDefaults.standard.removeObject(forKey: "watchlist")
        UserDefaults.standard.removeObject(forKey: "reviews")
        UserDefaults.standard.removeObject(forKey: "favoriteGenres")
    }
    
    private var headerView: some View {
        VStack(spacing: 5) {
            Text("Streamify Go")
                .font(.system(size: 24, weight: .light))
                .foregroundColor(.white)
            
            Text("Cinema Vault")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
        }
    }
    
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Your Stats")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 15) {
                StatCard(
                    title: "Movies Watched",
                    value: "\(movieManager.myMovies.filter { $0.isWatched }.count)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                StatCard(
                    title: "Total Collection",
                    value: "\(movieManager.myMovies.count)",
                    icon: "archivebox.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "Watchlist",
                    value: "\(movieManager.watchlist.count)",
                    icon: "heart.fill",
                    color: .red
                )
                
                StatCard(
                    title: "Avg Rating",
                    value: averageRating,
                    icon: "star.fill",
                    color: .yellow
                )
            }
        }
    }
    
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Recent Activity")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
            
            if movieManager.myMovies.isEmpty {
                Text("No recent activity")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.vertical, 20)
            } else {
                VStack(spacing: 12) {
                    ForEach(movieManager.myMovies.prefix(3)) { movie in
                        ActivityRow(movie: movie)
                    }
                }
            }
        }
    }
    
    private var favoriteGenresSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Favorite Genres")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
            
            let genreStats = calculateGenreStats()
            
            if genreStats.isEmpty {
                Text("No genres tracked yet")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.vertical, 20)
            } else {
                VStack(spacing: 10) {
                    ForEach(genreStats.prefix(5), id: \.genre) { stat in
                        GenreStatRow(genre: stat.genre, count: stat.count, percentage: stat.percentage)
                    }
                }
            }
        }
    }
    
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Settings")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                SettingRow(
                    icon: "chart.bar.fill",
                    title: "Movie Analytics",
                    subtitle: "Detailed insights & recommendations"
                ) {
                    showingMovieStats = true
                }
                
                SettingRow(
                    icon: "square.and.arrow.up",
                    title: "Export Data",
                    subtitle: "Backup your movie collection"
                ) {
                    showingExportAlert = true
                }
                
                SettingRow(
                    icon: "trash.fill",
                    title: "Clear All Data",
                    subtitle: "Reset your collection",
                    isDestructive: true
                ) {
                    showingClearAlert = true
                }
            }
        }
    }
    
    private var averageRating: String {
        let ratings = movieManager.myMovies.compactMap { $0.personalRating > 0 ? $0.personalRating : nil }
        guard !ratings.isEmpty else { return "0.0" }
        let average = ratings.reduce(0, +) / Double(ratings.count)
        return String(format: "%.1f", average)
    }
    
    private func calculateGenreStats() -> [GenreStat] {
        let genres = movieManager.myMovies.map { $0.genre }
        let genreCounts = Dictionary(grouping: genres, by: { $0 }).mapValues { $0.count }
        let total = genres.count
        
        return genreCounts.map { genre, count in
            GenreStat(
                genre: genre,
                count: count,
                percentage: total > 0 ? Double(count) / Double(total) : 0
            )
        }.sorted { $0.count > $1.count }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct ActivityRow: View {
    let movie: CinemaMovie
    
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(movie.posterColor.color)
                .frame(width: 40, height: 55)
                .overlay(
                    Image(systemName: "film")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.8))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Added \(movie.title)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(timeAgo(from: movie.dateAdded))
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            if movie.isWatched {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
    
    private func timeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct GenreStat {
    let genre: String
    let count: Int
    let percentage: Double
}

struct GenreStatRow: View {
    let genre: String
    let count: Int
    let percentage: Double
    
    var body: some View {
        HStack {
            Text(genre)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
            
            Spacer()
            
            Text("\(count)")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.white.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.purple)
                        .frame(width: geometry.size.width * percentage, height: 8)
                }
            }
            .frame(width: 60, height: 8)
        }
        .padding(.vertical, 4)
    }
}

struct SettingRow: View {
    let icon: String
    let title: String
    let subtitle: String
    var isDestructive: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(isDestructive ? .red : .purple)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(15)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isDestructive ? Color.red.opacity(0.3) : Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var movieManager: MovieManager
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Settings")
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(.white)
                    .padding()
                
                Spacer()
                
                Text("Settings coming soon...")
                    .foregroundColor(.white.opacity(0.7))
                
                Spacer()
            }
            .background(
                Color.black
                    .ignoresSafeArea()
            )
            .navigationBarHidden(true)
            .overlay(
                HStack {
                    Button("Done") {
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
    }
}

struct ExportData: Codable {
    let movies: [CinemaMovie]
    let watchlist: [CinemaMovie]
    let reviews: [MovieReview]
    let exportDate: Date = Date()
}

struct MovieAnalyticsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var movieManager: MovieManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    VStack(spacing: 10) {
                        Text("Movie Analytics")
                            .font(.system(size: 28, weight: .light))
                            .foregroundColor(.white)
                        
                        Text("Discover your movie patterns")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.top, 20)
                    
                    // Analytics Cards
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 15) {
                        AnalyticsCard(
                            title: "Watch Time",
                            value: "\(totalWatchTime)h",
                            icon: "clock.fill",
                            color: .blue
                        )
                        
                        AnalyticsCard(
                            title: "Avg Rating",
                            value: averagePersonalRating,
                            icon: "star.fill",
                            color: .yellow
                        )
                        
                        AnalyticsCard(
                            title: "Top Genre",
                            value: topGenre,
                            icon: "film.fill",
                            color: .purple
                        )
                        
                        AnalyticsCard(
                            title: "This Month",
                            value: "\(moviesThisMonth)",
                            icon: "calendar",
                            color: .green
                        )
                    }
                    
                    // Recommendations
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Recommendations")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                        
                        VStack(spacing: 12) {
                            RecommendationCard(
                                title: "Explore New Genres",
                                subtitle: "Try \(suggestedGenre) movies",
                                icon: "sparkles"
                            )
                            
                            RecommendationCard(
                                title: "Rate More Movies",
                                subtitle: "\(unratedCount) movies need ratings",
                                icon: "star.circle"
                            )
                            
                            RecommendationCard(
                                title: "Complete Watchlist",
                                subtitle: "\(movieManager.watchlist.count) movies waiting",
                                icon: "list.bullet"
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .background(Color.black.ignoresSafeArea())
            .navigationBarHidden(true)
            .overlay(
                HStack {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.purple)
                    )
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 10),
                alignment: .top
            )
        }
    }
    
    private var totalWatchTime: Int {
        movieManager.myMovies.filter { $0.isWatched }.reduce(0) { $0 + $1.duration } / 60
    }
    
    private var averagePersonalRating: String {
        let ratings = movieManager.myMovies.compactMap { $0.personalRating > 0 ? $0.personalRating : nil }
        guard !ratings.isEmpty else { return "0.0" }
        let average = ratings.reduce(0, +) / Double(ratings.count)
        return String(format: "%.1f", average)
    }
    
    private var topGenre: String {
        let genres = movieManager.myMovies.map { $0.genre }
        let genreCounts = Dictionary(grouping: genres, by: { $0 }).mapValues { $0.count }
        return genreCounts.max(by: { $0.value < $1.value })?.key ?? "None"
    }
    
    private var moviesThisMonth: Int {
        let calendar = Calendar.current
        let now = Date()
        return movieManager.myMovies.filter { 
            calendar.isDate($0.dateAdded, equalTo: now, toGranularity: .month)
        }.count
    }
    
    private var suggestedGenre: String {
        let allGenres = ["Action", "Comedy", "Drama", "Horror", "Sci-Fi", "Romance", "Thriller"]
        let userGenres = Set(movieManager.myMovies.map { $0.genre })
        let unexplored = allGenres.filter { !userGenres.contains($0) }
        return unexplored.randomElement() ?? "Drama"
    }
    
    private var unratedCount: Int {
        movieManager.myMovies.filter { $0.personalRating == 0 }.count
    }
}

struct AnalyticsCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct RecommendationCard: View {
    let title: String
    let subtitle: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.purple)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

#Preview {
    ProfileView()
        .environmentObject(MovieManager())
}
