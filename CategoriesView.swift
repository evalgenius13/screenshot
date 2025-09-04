import SwiftUI

func categoryCover(for category: String) -> Image {
    let name = category.lowercased()
    return Image(name) // loads from Assets.xcassets
}

struct CategoriesView: View {
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(CATEGORY_LIST, id: \.self) { category in
                        NavigationLink(destination: ScreenshotCategoryGrid(category: category)) {
                            VStack {
                                categoryCover(for: category)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                    .cornerRadius(8)
                                Text(category)
                                    .font(.caption)
                                    .foregroundColor(.primary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Categories")
        }
    }
}

struct ScreenshotCategoryGrid: View {
    let category: String
    @FetchRequest var screenshots: FetchedResults<ScreenshotEntity>

    init(category: String) {
        self.category = category
        _screenshots = FetchRequest(
            entity: ScreenshotEntity.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \ScreenshotEntity.date, ascending: false)],
            predicate: NSPredicate(format: "category == %@", category)
        )
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(screenshots, id: \.objectID) { screenshot in
                    if let imageData = screenshot.thumbnail,
                       let uiImage = UIImage(data: imageData) {
                        NavigationLink(destination: ScreenshotDetailView(screenshot: screenshot)) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 150, height: 150)
                                .clipped()
                                .cornerRadius(8)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(category)
    }
}
