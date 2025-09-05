import SwiftUI
import CoreData

struct SearchView: View {
    @Environment(\.managedObjectContext) private var context

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ScreenshotEntity.date, ascending: false)],
        animation: .default
    ) private var screenshots: FetchedResults<ScreenshotEntity>

    @State private var selectedIndex: Int? = nil
    @State private var selectedGroup: [ScreenshotEntity] = []

    private var groupedScreenshots: [(String, [ScreenshotEntity])] {
        let dict = Dictionary(grouping: screenshots) { (s: ScreenshotEntity) -> String in
            s.folder?.name ?? "Other"
        }
        return dict.keys.sorted().map { ($0, dict[$0] ?? []) }
    }

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 4)

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    ForEach(groupedScreenshots, id: \.0) { (categoryName, items) in
                        if !items.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(categoryName)
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 8)

                                LazyVGrid(columns: columns, spacing: 4) {
                                    ForEach(items.indices, id: \.self) { index in
                                        if let data = items[index].thumbnail,
                                           let uiImage = UIImage(data: data),
                                           !items[index].isLikelyTextScreenshot,
                                           !isDarkOrFlat(uiImage) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(height: 90)
                                                .clipped()
                                                .onTapGesture {
                                                    selectedIndex = index
                                                    selectedGroup = items
                                                }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.top, 12)
            }
            .navigationTitle("Search")
            .fullScreenCover(isPresented: Binding(
                get: { selectedIndex != nil },
                set: { if !$0 { selectedIndex = nil } }
            )) {
                if let i = selectedIndex {
                    ScreenshotPreviewView(
                        screenshots: selectedGroup,
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

