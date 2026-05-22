import SwiftUI

struct MovieDetailView: View {
    let movie: CinemaMovie
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var movieManager: MovieManager
    @State private var showingEditView = false
    @State private var showingReviewSheet = false
    @State private var showingTicketBooking = false
    @State private var scrollOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Hero Section
                    heroSection
                    
                    // Content
                    contentSection
                }
            }
            .coordinateSpace(name: "scroll")
            
            // Floating Header
            floatingHeader
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingEditView) {
            EditMovieView(movie: movie)
                .environmentObject(movieManager)
        }
        .sheet(isPresented: $showingReviewSheet) {
            AddReviewView(movie: movie)
                .environmentObject(movieManager)
        }
        .sheet(isPresented: $showingTicketBooking) {
            BookTicketView(movie: movie)
                .environmentObject(movieManager)
        }
    }
    
    private var heroSection: some View {
        GeometryReader { geometry in
            let offset = geometry.frame(in: .named("scroll")).minY
            
            ZStack {
                // Background Poster
                RoundedRectangle(cornerRadius: 0)
                    .fill(movie.posterColor.color)
                    .frame(height: 400 + (offset > 0 ? offset : 0))
                    .clipped()
                    .offset(y: offset > 0 ? -offset : 0)
                
                // Overlay
                LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.8)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 400 + (offset > 0 ? offset : 0))
                .offset(y: offset > 0 ? -offset : 0)
                
                // Content
                VStack(spacing: 20) {
                    Spacer()
                    
                    // Movie Poster
                    RoundedRectangle(cornerRadius: 20)
                        .fill(movie.posterColor.color)
                        .frame(width: 150, height: 200)
                        .overlay(
                            Group {
                                if let posterImage = movie.posterImage {
                                    Image(uiImage: posterImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 150, height: 200)
                                        .clipped()
                                        .cornerRadius(20)
                                } else {
                                    VStack {
                                        Image(systemName: "film")
                                            .font(.system(size: 40))
                                            .foregroundColor(.white.opacity(0.8))
                                        
                                        if movie.isWatched {
                                            Spacer()
                                            HStack {
                                                Spacer()
                                                Image(systemName: "checkmark.circle.fill")
                                                    .font(.system(size: 24))
                                                    .foregroundColor(.green)
                                                    .background(Circle().fill(.black.opacity(0.5)))
                                            }
                                            .padding(12)
                                        }
                                    }
                                }
                            }
                        )
                        .overlay(
                            // Overlay for watched status on images
                            Group {
                                if movie.posterImage != nil && movie.isWatched {
                                    VStack {
                                        HStack {
                                            Spacer()
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 24))
                                                .foregroundColor(.green)
                                                .background(Circle().fill(.black.opacity(0.7)))
                                        }
                                        .padding(12)
                                        Spacer()
                                    }
                                }
                            }
                        )
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    
                    // Title and Director
                    VStack(spacing: 8) {
                        Text(movie.title)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text("Directed by \(movie.director)")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
        }
        .frame(height: 400)
    }
    
    private var contentSection: some View {
        VStack(spacing: 25) {
            // Quick Info
            quickInfoSection
            
            // Ratings
            ratingsSection
            
            // Synopsis
            synopsisSection
            
            // Personal Notes
            if !movie.notes.isEmpty {
                personalNotesSection
            }
            
            // Actions
            actionsSection
            
            // Reviews
            reviewsSection
        }
        .padding(.horizontal, 20)
        .padding(.top, 30)
        .padding(.bottom, 50)
    }
    
    private var quickInfoSection: some View {
        HStack(spacing: 20) {
            InfoCard(title: "Genre", value: movie.genre, icon: "theatermasks")
            InfoCard(title: "Year", value: "\(movie.releaseYear)", icon: "calendar")
            InfoCard(title: "Duration", value: movie.durationFormatted, icon: "clock")
        }
    }
    
    private var ratingsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Ratings")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
            
            HStack(spacing: 30) {
                // IMDb Rating
                VStack(spacing: 8) {
                    Text("IMDb")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        
                        Text("\(movie.imdbRating, specifier: "%.1f")")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                
                // Personal Rating
                VStack(spacing: 8) {
                    Text("Your Rating")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                    
                    if movie.personalRating > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.purple)
                            
                            Text("\(movie.personalRating, specifier: "%.1f")")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                        }
                    } else {
                        Button(action: { showingReviewSheet = true }) {
                            Text("Rate")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.purple)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.purple, lineWidth: 1)
                                )
                        }
                    }
                }
                
                Spacer()
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.ultraThinMaterial)
        )
    }
    
    private var synopsisSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Synopsis")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
            
            Text(movie.synopsis.isEmpty ? "No synopsis available." : movie.synopsis)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.white.opacity(0.8))
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.ultraThinMaterial)
        )
    }
    
    private var personalNotesSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Personal Notes")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
            
            Text(movie.notes)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.white.opacity(0.8))
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
    
    private var actionsSection: some View {
        VStack(spacing: 15) {
            // Primary Actions
            HStack(spacing: 15) {
                ActionButton(
                    title: movie.isWatched ? "Mark Unwatched" : "Mark Watched",
                    icon: movie.isWatched ? "checkmark.circle.fill" : "circle",
                    color: movie.isWatched ? .green : .blue,
                    isPrimary: true
                ) {
                    withAnimation {
                        movieManager.toggleWatched(movie.id)
                    }
                }
                
                ActionButton(
                    title: "Add Review",
                    icon: "star.circle",
                    color: .purple,
                    isPrimary: false
                ) {
                    showingReviewSheet = true
                }
            }
            
            // Secondary Actions
            HStack(spacing: 15) {
                ActionButton(
                    title: "Book Ticket",
                    icon: "ticket.fill",
                    color: .pink,
                    isPrimary: false
                ) {
                    showingTicketBooking = true
                }
                
                ActionButton(
                    title: "Edit Movie",
                    icon: "pencil.circle",
                    color: .orange,
                    isPrimary: false
                ) {
                    showingEditView = true
                }
            }
            
            HStack(spacing: 15) {
                ActionButton(
                    title: "Add to Watchlist",
                    icon: "heart.circle",
                    color: .red,
                    isPrimary: false
                ) {
                    movieManager.addToWatchlist(movie)
                }
                
                Spacer()
            }
        }
    }
    
    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Reviews")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: { showingReviewSheet = true }) {
                    Image(systemName: "plus.circle")
                        .foregroundColor(.purple)
                }
            }
            
            let movieReviews = movieManager.reviews.filter { $0.movieId == movie.id }
            
            if movieReviews.isEmpty {
                Text("No reviews yet. Be the first to review!")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.vertical, 20)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(movieReviews) { review in
                        ReviewCard(review: review)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.ultraThinMaterial)
        )
    }
    
    private var floatingHeader: some View {
        VStack {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
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
                
                Spacer()
                
                Button(action: { showingEditView = true }) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
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
            .padding(.top, 50)
            
            Spacer()
        }
    }
}

struct InfoCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.purple)
            
            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 15)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let isPrimary: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(isPrimary ? .white : color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isPrimary ? color : .clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(color, lineWidth: isPrimary ? 0 : 1)
                    )
            )
        }
    }
}

struct ReviewCard: View {
    let review: MovieReview
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 4) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Double(star) <= review.rating ? .yellow : .gray)
                    }
                }
                
                Spacer()
                
                Text(review.dateCreated, style: .date)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Text(review.reviewText)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))
                .lineSpacing(2)
        }
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThinMaterial)
        )
    }
}

struct AddReviewView: View {
    let movie: CinemaMovie
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var movieManager: MovieManager
    @State private var rating: Double = 5.0
    @State private var reviewText = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 25) {
                Text("Add Review")
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(.white)
                
                Text("for \(movie.title)")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
                
                // Rating
                VStack(spacing: 15) {
                    Text("Rating: \(rating, specifier: "%.0f")/10")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 8) {
                        ForEach(1...10, id: \.self) { star in
                            Button(action: { rating = Double(star) }) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(Double(star) <= rating ? .yellow : .gray)
                            }
                        }
                    }
                }
                
                // Review Text
                VStack(alignment: .leading, spacing: 10) {
                    Text("Review")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    
                    TextEditor(text: $reviewText)
                        .frame(height: 120)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.ultraThinMaterial)
                        )
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Button("Add Review") {
                    let review = MovieReview(
                        movieId: movie.id,
                        rating: rating,
                        reviewText: reviewText
                    )
                    movieManager.addReview(review)
                    movieManager.updateMovieRating(movie.id, rating: rating)
                    dismiss()
                }
                .disabled(reviewText.isEmpty)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(reviewText.isEmpty ? .gray : .purple)
                )
            }
            .padding(20)
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
    }
}

struct EditMovieView: View {
    let movie: CinemaMovie
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var movieManager: MovieManager
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Edit Movie")
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(.white)
                    .padding()
                
                Spacer()
                
                Text("Edit functionality coming soon...")
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

struct BookTicketView: View {
    let movie: CinemaMovie
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var movieManager: MovieManager
    
    @State private var theater = "Cineplex Theater"
    @State private var showDate = Date()
    @State private var showTime = "7:00 PM"
    @State private var seatNumber = "A12"
    @State private var price = 12.50
    
    let theaters = ["Cineplex Theater", "AMC Cinema", "Regal Movies", "IMAX Theater"]
    let showTimes = ["2:00 PM", "5:00 PM", "7:00 PM", "9:30 PM"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    VStack(spacing: 10) {
                        Text("Book Ticket")
                            .font(.system(size: 28, weight: .light))
                            .foregroundColor(.white)
                        
                        Text("for \(movie.title)")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.top, 20)
                    
                    // Movie Poster
                    HStack {
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
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(movie.title)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Text(movie.director)
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.7))
                            
                            Text("\(movie.genre) • \(movie.durationFormatted)")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        
                        Spacer()
                    }
                    .padding(15)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.ultraThinMaterial)
                    )
                    
                    // Booking Form
                    VStack(spacing: 20) {
                        // Theater Selection
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Theater")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(theaters, id: \.self) { theaterOption in
                                        Button(action: { theater = theaterOption }) {
                                            Text(theaterOption)
                                                .font(.system(size: 14))
                                                .foregroundColor(theater == theaterOption ? .black : .white)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 8)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .fill(theater == theaterOption ? .pink : .clear)
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
                        
                        // Date Selection
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Show Date")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                            
                            DatePicker("", selection: $showDate, displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                                .colorScheme(.dark)
                        }
                        
                        // Time Selection
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Show Time")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                            
                            HStack(spacing: 10) {
                                ForEach(showTimes, id: \.self) { time in
                                    Button(action: { showTime = time }) {
                                        Text(time)
                                            .font(.system(size: 14))
                                            .foregroundColor(showTime == time ? .black : .white)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .fill(showTime == time ? .pink : .clear)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 20)
                                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                                    )
                                            )
                                    }
                                }
                            }
                        }
                        
                        // Seat and Price
                        HStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Seat")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                
                                TextField("A12", text: $seatNumber)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .foregroundColor(.white)
                                    .padding(12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(.ultraThinMaterial)
                                    )
                            }
                            
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Price ($)")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                
                                TextField("12.50", value: $price, format: .number)
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
                    .padding(.horizontal, 20)
                    
                    // Book Button
                    Button("Book Ticket") {
                        bookTicket()
                    }
                    .foregroundColor(.black)
                    .font(.system(size: 18, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.pink)
                    )
                    .padding(.horizontal, 20)
                }
            }
            .background(Color.black.ignoresSafeArea())
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
    }
    
    private func bookTicket() {
        let ticket = MovieTicket(
            movieId: movie.id,
            movieTitle: movie.title,
            theater: theater,
            showDate: showDate,
            showTime: showTime,
            seatNumber: seatNumber,
            price: price
        )
        
        movieManager.addTicket(ticket)
        dismiss()
    }
}

#Preview {
    MovieDetailView(movie: CinemaMovie(
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
    ))
    .environmentObject(MovieManager())
}
