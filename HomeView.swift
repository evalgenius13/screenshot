import SwiftUI
import CoreData

struct HomeView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ScreenshotEntity.date, ascending: false)],
        animation: .default
    ) private var screenshots: FetchedResults<ScreenshotEntity>

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)
    @State private var selectedIndex: Int? = nil

    // ✅ Only keep valid thumbnails → keeps Recents light
    private var visualScreenshots: [ScreenshotEntity] {
        screenshots.filter {
            guard !$0.isLikelyTextScreenshot else { return false }
            if let data = $0.thumbnail,
               let uiImage = UIImage(data: data) {
                return !isDarkOrFlat(uiImage)
            }
            return false
        }
    }

    var body: some View {
        NavigationView {
            if visualScreenshots.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("No Visual Screenshots Found")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 2) {
                        ForEach(visualScreenshots.indices, id: \.self) { index in
                            if let data = visualScreenshots[index].thumbnail,
                               let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .interpolation(.none)
                                    .antialiased(false)
                                    .scaledToFill()
                                    .frame(height: 140)
                                    .clipped()
                                    .onTapGesture {
                                        selectedIndex = index
                                    }
                            }
                        }
                    }
                }
                .navigationTitle("Recent")
                .fullScreenCover(isPresented: Binding(
                    get: { selectedIndex != nil },
                    set: { if !$0 { selectedIndex = nil } }
                )) {
                    if let i = selectedIndex {
                        ScreenshotPreviewView(
                            screenshots: visualScreenshots,
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
}

