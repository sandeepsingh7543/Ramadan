import SwiftUI
import PhotosUI

struct AddMovieView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var movieManager: MovieManager
    
    @State private var title = ""
    @State private var director = ""
    @State private var genre = "Action"
    @State private var releaseYear = 2024
    @State private var duration = 120
    @State private var synopsis = ""
    @State private var imdbRating = 7.0
    @State private var personalRating = 0.0
    @State private var selectedColor = Color.blue
    @State private var isWatched = false
    @State private var notes = ""
    @State private var currentStep = 0
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    
    let genres = ["Action", "Comedy", "Drama", "Horror", "Sci-Fi", "Romance", "Thriller", "Animation", "Documentary", "Fantasy"]
    let colors: [Color] = [.blue, .purple, .red, .orange, .green, .pink, .yellow, .cyan, .indigo, .mint]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    // Progress Indicator
                    progressIndicator
                    
                    // Content
                    TabView(selection: $currentStep) {
                        basicInfoStep.tag(0)
                        detailsStep.tag(1)
                        ratingsStep.tag(2)
                        customizationStep.tag(3)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    
                    // Navigation Buttons
                    navigationButtons
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
    }
    
    private var headerView: some View {
        HStack {
            Button("Cancel") {
                dismiss()
            }
            .foregroundColor(.white)
            
            Spacer()
            
            Text("Add Movie")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer()
            
            Button("Save") {
                saveMovie()
            }
            .foregroundColor(canSave ? .purple : .gray)
            .disabled(!canSave)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    private var progressIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<4) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(index <= currentStep ? Color.purple : Color.white.opacity(0.3))
                    .frame(height: 4)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
    }
    
    private var basicInfoStep: some View {
        ScrollView {
            VStack(spacing: 25) {
                stepHeader(
                    title: "Basic Information",
                    subtitle: "Tell us about the movie"
                )
                
                VStack(spacing: 20) {
                    CustomTextField(title: "Movie Title", text: $title)
                    CustomTextField(title: "Director", text: $director)
                    
                    // Genre Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Genre")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 10) {
                            ForEach(genres, id: \.self) { genreOption in
                                Button(action: { genre = genreOption }) {
                                    Text(genreOption)
                                        .font(.system(size: 14))
                                        .foregroundColor(genre == genreOption ? .black : .white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(genre == genreOption ? .white : .clear)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                                )
                                        )
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    private var detailsStep: some View {
        ScrollView {
            VStack(spacing: 25) {
                stepHeader(
                    title: "Movie Details",
                    subtitle: "Add more information"
                )
                
                VStack(spacing: 20) {
                    // Release Year
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Release Year: \(releaseYear)")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        
                        Slider(value: Binding(
                            get: { Double(releaseYear) },
                            set: { releaseYear = Int($0) }
                        ), in: 1900...2030, step: 1)
                        .accentColor(.purple)
                    }
                    
                    // Duration
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Duration: \(duration) minutes (\(duration/60)h \(duration%60)m)")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        
                        Slider(value: Binding(
                            get: { Double(duration) },
                            set: { duration = Int($0) }
                        ), in: 60...300, step: 5)
                        .accentColor(.purple)
                    }
                    
                    CustomTextField(
                        title: "Synopsis",
                        text: $synopsis,
                        isMultiline: true
                    )
                    
                    CustomTextField(
                        title: "Personal Notes",
                        text: $notes,
                        isMultiline: true
                    )
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    private var ratingsStep: some View {
        ScrollView {
            VStack(spacing: 25) {
                stepHeader(
                    title: "Ratings & Status",
                    subtitle: "Rate and track the movie"
                )
                
                VStack(spacing: 25) {
                    // IMDb Rating
                    VStack(alignment: .leading, spacing: 15) {
                        Text("IMDb Rating: \(imdbRating, specifier: "%.1f")")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 8) {
                            ForEach(1...10, id: \.self) { rating in
                                Button(action: { imdbRating = Double(rating) }) {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(Double(rating) <= imdbRating ? .yellow : .gray)
                                }
                            }
                        }
                    }
                    
                    // Personal Rating
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Your Rating: \(personalRating > 0 ? String(format: "%.1f", personalRating) : "Not rated")")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 8) {
                            ForEach(0...10, id: \.self) { rating in
                                Button(action: { personalRating = Double(rating) }) {
                                    Image(systemName: rating == 0 ? "xmark.circle" : "star.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(
                                            rating == 0 ? (personalRating == 0 ? .red : .gray) :
                                            (Double(rating) <= personalRating ? .purple : .gray)
                                        )
                                }
                            }
                        }
                    }
                    
                    // Watched Status
                    HStack {
                        Text("Have you watched this movie?")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: { isWatched.toggle() }) {
                            Image(systemName: isWatched ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 24))
                                .foregroundColor(isWatched ? .green : .white.opacity(0.6))
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    private var customizationStep: some View {
        ScrollView {
            VStack(spacing: 25) {
                stepHeader(
                    title: "Customization",
                    subtitle: "Make it uniquely yours"
                )
                
                VStack(spacing: 25) {
                    // Image Selection
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Movie Poster")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        
                        Button(action: { showingImagePicker = true }) {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(selectedColor.opacity(0.3))
                                .frame(height: 200)
                                .overlay(
                                    Group {
                                        if let image = selectedImage {
                                            Image(uiImage: image)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(height: 200)
                                                .clipped()
                                                .cornerRadius(15)
                                        } else {
                                            VStack(spacing: 10) {
                                                Image(systemName: "photo.badge.plus")
                                                    .font(.system(size: 40))
                                                    .foregroundColor(.white.opacity(0.7))
                                                
                                                Text("Add Poster Image")
                                                    .font(.system(size: 16))
                                                    .foregroundColor(.white.opacity(0.7))
                                            }
                                        }
                                    }
                                )
                        }
                    }
                    
                    // Color Selection
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Poster Color")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 15) {
                            ForEach(colors, id: \.self) { color in
                                Button(action: { selectedColor = color }) {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(color)
                                        .frame(height: 50)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.white, lineWidth: selectedColor == color ? 3 : 0)
                                        )
                                        .overlay(
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(.white)
                                                .opacity(selectedColor == color ? 1 : 0)
                                        )
                                }
                            }
                        }
                    }
                    
                    // Preview
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Preview")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        
                        HStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedColor)
                                .frame(width: 80, height: 110)
                                .overlay(
                                    Group {
                                        if let image = selectedImage {
                                            Image(uiImage: image)
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
                                Text(title.isEmpty ? "Movie Title" : title)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .lineLimit(2)
                                
                                Text(director.isEmpty ? "Director Name" : director)
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.7))
                                
                                HStack {
                                    Text(genre)
                                        .font(.system(size: 12))
                                        .foregroundColor(.purple)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(.purple.opacity(0.2))
                                        )
                                    
                                    Spacer()
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(15)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(.ultraThinMaterial)
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    private var navigationButtons: some View {
        HStack(spacing: 20) {
            if currentStep > 0 {
                Button("Previous") {
                    withAnimation {
                        currentStep -= 1
                    }
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
            }
            
            Spacer()
            
            if currentStep < 3 {
                Button("Next") {
                    withAnimation {
                        currentStep += 1
                    }
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(.purple)
                )
                .disabled(!canProceed)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
    }
    
    private var canProceed: Bool {
        switch currentStep {
        case 0:
            return !title.isEmpty && !director.isEmpty
        default:
            return true
        }
    }
    
    private var canSave: Bool {
        !title.isEmpty && !director.isEmpty
    }
    
    private func stepHeader(title: String, subtitle: String) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 24, weight: .light))
                .foregroundColor(.white)
            
            Text(subtitle)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.top, 20)
    }
    
    private func saveMovie() {
        let movie = CinemaMovie(
            title: title,
            director: director,
            genre: genre,
            releaseYear: releaseYear,
            duration: duration,
            synopsis: synopsis,
            imdbRating: imdbRating,
            personalRating: personalRating,
            posterColor: selectedColor,
            isWatched: isWatched,
            notes: notes,
            posterImage: selectedImage
        )
        
        movieManager.addMovie(movie)
        dismiss()
    }
}

struct CustomTextField: View {
    let title: String
    @Binding var text: String
    var isMultiline: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
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
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
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
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
            }
        }
    }
}

#Preview {
    AddMovieView()
        .environmentObject(MovieManager())
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
