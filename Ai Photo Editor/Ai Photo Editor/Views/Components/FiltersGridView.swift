import SwiftUI

struct FiltersGridView: View {
    @ObservedObject var viewModel: PhotoEditorViewModel
    @Environment(\.colorScheme) var colorScheme
    
    let filters: [(String, String, FilterType)] = [
        ("Original", "photo", .original),
        ("B&W", "circle.lefthalf.filled", .blackAndWhite),
        ("Vintage", "camera.filters", .vintage),
        ("Cinematic", "film", .cinematic),
        ("Warm", "sun.max.fill", .warm),
        ("Cool", "snowflake", .cool),
        ("Sepia", "photo.fill", .sepia),
        ("Vivid", "sparkles", .vivid)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Filters")
                .font(.headline)
                .foregroundColor(colorScheme == .dark ? .white : .black)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(filters, id: \.2) { name, icon, filter in
                    FilterButton(name: name, icon: icon, isSelected: viewModel.selectedFilter == filter) {
                        viewModel.applyFilter(filter)
                    }
                }
            }
        }
    }
}

struct FilterButton: View {
    let name: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(isSelected ? .white : (colorScheme == .dark ? .gray : .blue))
                Text(name)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : (colorScheme == .dark ? .white : .black))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(isSelected ? Color.blue : (colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray6)))
            .cornerRadius(10)
        }
    }
}
