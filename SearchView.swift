import SwiftUI
import CoreData

struct SearchView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
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
    
    @State private var query: String = ""
    
    // Group screenshots by category (with optional filtering)
    private var groupedScreenshots: [CategoryEntity: [ScreenshotEntity]] {
        let filtered: [ScreenshotEntity]
        if query.isEmpty {
            filtered = Array(screenshots)
        } else {
            filtered = screenshots.filter { shot in
                shot.ocrText?.localizedCaseInsensitiveContains(query) ?? false
            }
        }
        return Dictionary(grouping: filtered, by: { $0.folder ?? CategoryEntity() })
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search bar
                TextField("Search…", text: $query)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                // Results grouped by category
                ScrollView {
                    ForEach(categories, id: \.self) { category in
                        if let items = groupedScreenshots[category], !items.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(category.name ?? "Unnamed")
                                    .font(.headline)
                                    .padding(.leading)
                                
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                    ForEach(items) { screenshot in
                                        if let path = screenshot.fullImagePath,
                                           let image = UIImage(contentsOfFile: path) {
                                            NavigationLink(
                                                destination: ScreenshotDetailView(
                                                    screenshot: screenshot,
                                                    allScreenshots: items
                                                )
                                            ) {
                                                Image(uiImage: image)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: UIScreen.main.bounds.width / 2 - 20, height: 180)
                                                    .clipped()
                                                    .cornerRadius(8)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .padding(.bottom, 20)
                        }
                    }
                }
                .padding(.bottom, 100) // space for global menu
            }
            .navigationTitle("Search")
            .navigationBarHidden(true)
        }
    }
}

