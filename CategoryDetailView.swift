import SwiftUI
import CoreData

struct CategoryDetailView: View {
    let category: CategoryEntity
    @Environment(\.managedObjectContext) private var context

    var screenshots: [ScreenshotEntity] {
        (category.screenshots as? Set<ScreenshotEntity>)?.sorted {
            ($0.date ?? Date()) > ($1.date ?? Date())
        } ?? []
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(screenshots, id: \.objectID) { shot in
                    if let data = shot.thumbnail, let uiImage = UIImage(data: data) {
                        NavigationLink(destination: ScreenshotDetailView(screenshot: shot)) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 160)
                                .clipped()
                                .cornerRadius(8)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(category.name ?? "Category")
        .navigationBarTitleDisplayMode(.inline)
    }
}

