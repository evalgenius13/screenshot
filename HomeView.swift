import SwiftUI
import CoreData

struct HomeView: View {
    @Environment(\.managedObjectContext) private var context
    
    // Fetch only the most recent 20 screenshots
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ScreenshotEntity.date, ascending: false)],
        predicate: nil,
        animation: .default
    ) private var allScreenshots: FetchedResults<ScreenshotEntity>
    
    @State private var selectedIndex: Int? = nil
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)
    
    // Cap to 20 most recent
    private var recentScreenshots: [ScreenshotEntity] {
        Array(allScreenshots.prefix(20))
    }

    var body: some View {
        NavigationView {
            ScrollView {
                if recentScreenshots.isEmpty {
                    VStack {
                        Spacer()
                        Text("No screenshots yet")
                            .foregroundColor(.secondary)
                            .padding()
                        Spacer()
                    }
                } else {
                    LazyVGrid(columns: columns, spacing: 2) {
                        ForEach(recentScreenshots.indices, id: \.self) { index in
                            let shot = recentScreenshots[index]
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
            .navigationTitle("Recents")
            .fullScreenCover(
                isPresented: Binding(
                    get: { selectedIndex != nil },
                    set: { if !$0 { selectedIndex = nil } }
                )
            ) {
                if let i = selectedIndex {
                    ScreenshotPreviewView(
                        screenshots: recentScreenshots,
                        selectedIndex: Binding(
                            get: { i },
                            set: { selectedIndex = $0 }
                        )
                    )
                }
            }
        }
    }
}

