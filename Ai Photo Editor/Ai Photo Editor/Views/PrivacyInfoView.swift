import SwiftUI

struct PrivacyInfoView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    privacySection(
                        icon: "lock.shield.fill",
                        title: "100% Private & Secure",
                        description: "All photo editing happens directly on your device. Your photos never leave your iPhone or iPad."
                    )
                    
                    privacySection(
                        icon: "icloud.slash.fill",
                        title: "No Cloud Upload",
                        description: "We don't upload, store, or transmit your photos to any server. Everything stays on your device."
                    )
                    
                    privacySection(
                        icon: "eye.slash.fill",
                        title: "No Data Collection",
                        description: "We don't collect, track, or share any personal information or usage data."
                    )
                    
                    privacySection(
                        icon: "wifi.slash",
                        title: "Works Offline",
                        description: "The app works completely offline. No internet connection required for any feature."
                    )
                    
                    privacySection(
                        icon: "photo.fill",
                        title: "Photo Library Access",
                        description: "We only access photos you explicitly select. We need permission to save edited photos back to your library."
                    )
                    
                    Divider()
                        .padding(.vertical)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("How We Use Permissions")
                            .font(.headline)
                        
                        Text("• Photo Library: To let you select and save photos")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("• No other permissions required")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
            .navigationTitle("Privacy & Security")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func privacySection(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
