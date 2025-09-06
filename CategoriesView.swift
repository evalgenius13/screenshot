import SwiftUI
import CoreData

struct CategoriesView: View {
    @FetchRequest(
        sortDescriptors: [],
        animation: .default
    )
    private var categories: FetchedResults<CategoryEntity>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ScreenshotEntity.date, ascending: false)],
        animation: .default
    )
    private var screenshots: FetchedResults<ScreenshotEntity>
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(categories, id: \.self) { category in
                        NavigationLink(
                            destination: CategoryDetailView(category: category)
                        ) {
                            CategoryTile(category: category)
                        }
                    }
                }
                .padding()
                .padding(.bottom, 100) // keep space so menu doesn’t cover content
            }
            .navigationTitle("Categories")
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Category Tile
struct CategoryTile: View {
    let category: CategoryEntity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let screenshots = category.screenshots as? Set<ScreenshotEntity>,
               let first = screenshots.first,
               let thumbData = first.thumbnail,
               let thumb = UIImage(data: thumbData) {
                Image(uiImage: thumb)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 140)
                    .clipped()
                    .cornerRadius(10)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 140)
                    .cornerRadius(10)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    )
            }
            
            Text(category.name ?? "Unnamed")
                .font(.headline)
                .lineLimit(1)
        }
    }
}

