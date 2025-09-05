import SwiftUI
import CoreData

struct SearchView: View {
    @Environment(\.managedObjectContext) private var context
    
    @State private var query = ""
    @State private var results: [ScreenshotEntity] = []
    @State private var selectedIndex: Int? = nil

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)

    var body: some View {
        NavigationView {
            VStack {
                TextField("Search screenshots…", text: $query)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 16)
                    .onChange(of: query) { _ in performSearch() }

                if query.isEmpty {
                    Spacer()
                    Text("Search by text or category")
                        .foregroundColor(.secondary)
                        .padding()
                    Spacer()
                } else {
                    if results.isEmpty {
                        Spacer()
                        Text("No results found")
                            .foregroundColor(.secondary)
                            .padding()
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 2) {
                                ForEach(results.indices, id: \.self) { index in
                                    let shot = results[index]
                                    ZStack(alignment: .topLeading) {
                                        if let data = shot.thumbnail,
                                           let uiImage = UIImage(data: data) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(height: 140)
                                                .clipped()
                                                .onTapGesture { selectedIndex = index }
                                        } else {
                                            Rectangle()
                                                .fill(Color.secondary.opacity(0.2))
                                                .frame(height: 140)
                                        }
                                        
                                        if shot.status == "pending" {
                                            Text("Scanning…")
                                                .font(.caption2)
                                                .padding(4)
                                                .background(Color.yellow.opacity(0.8))
                                                .cornerRadius(6)
                                                .padding(6)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Search")
            .fullScreenCover(
                isPresented: Binding(
                    get: { selectedIndex != nil },
                    set: { if !$0 { selectedIndex = nil } }
                )
            ) {
                if let i = selectedIndex {
                    ScreenshotPreviewView(
                        screenshots: results,
                        selectedIndex: Binding(
                            get: { i },
                            set: { selectedIndex = $0 }
                        )
                    )
                }
            }
        }
    }

    // MARK: - Search
    private func performSearch() {
        guard !query.isEmpty else {
            results = []
            return
        }

        let request: NSFetchRequest<ScreenshotEntity> = ScreenshotEntity.fetchRequest()
        request.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
            NSPredicate(format: "ocrText CONTAINS[cd] %@", query),
            NSPredicate(format: "folder.name CONTAINS[cd] %@", query)
        ])
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ScreenshotEntity.date, ascending: false)]

        do {
            results = try context.fetch(request)
        } catch {
            print("Search failed: \(error)")
            results = []
        }
    }
}

