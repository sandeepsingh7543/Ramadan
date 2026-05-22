import SwiftUI
import PhotosUI

struct HomeView: View {
    @State private var showPicker = false
    @State private var selectedImage: UIImage?
    @State private var navigateToEditor = false
    @State private var showPrivacyInfo = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    VStack(spacing: 16) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 80))
                            .foregroundColor(.white)
                        
                        Text("AI Photo Editor")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Smart Edit")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 12) {
                        Button {
                            showPicker = true
                        } label: {
                            HStack {
                                Image(systemName: "photo.on.rectangle")
                                    .font(.title3)
                                Text("Select Photo")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .foregroundColor(.white)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(12)
                        }
                        
                        Button {
                            showPrivacyInfo = true
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "lock.shield.fill")
                                    .font(.caption)
                                Text("Your Privacy")
                                    .font(.caption)
                            }
                            .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding(.horizontal, 40)
                    
                    NavigationLink(
                        destination: Group {
                            if let image = selectedImage {
                                EditorView(image: image)
                            }
                        },
                        isActive: $navigateToEditor
                    ) {
                        EmptyView()
                    }
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showPicker) {
                PhotoPicker(selectedImage: $selectedImage, navigateToEditor: $navigateToEditor)
            }
            .sheet(isPresented: $showPrivacyInfo) {
                PrivacyInfoView()
            }
        }
        .navigationViewStyle(.stack)
    }
}
