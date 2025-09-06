import SwiftUI
import CoreData

struct CategoryDetailView: View {
    @ObservedObject var category: CategoryEntity

    private var sortedScreenshots: [ScreenshotEntity] {
        (category.screenshots as? Set<ScreenshotEntity>)?
            .sorted { ($0.date ?? Date()) > ($1.date ?? Date()) } ?? []
    }

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 2)

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(sortedScreenshots, id: \.self) { screenshot in
                    if let thumbData = screenshot.thumbnail,
                       let uiImage = UIImage(data: thumbData) {
                        NavigationLink(
                            destination: ScreenshotDetailView(
                                screenshot: screenshot,
                                allScreenshots: sortedScreenshots
                            )
                        ) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 150)
                                .clipped()
                                .cornerRadius(8)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(category.name ?? "Category")
    }
}

