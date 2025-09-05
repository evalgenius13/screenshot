import SwiftUI
import CoreData

struct CategoryDetailView: View {
    let category: CategoryEntity
    @State private var selectedIndex: Int? = nil

    var body: some View {
        let shots = (category.screenshots as? Set<ScreenshotEntity>)?
            .sorted { ($0.date ?? .distantPast) > ($1.date ?? .distantPast) } ?? []

        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 3), spacing: 2) {
                ForEach(shots.indices, id: \.self) { index in
                    let shot = shots[index]
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
        .navigationTitle(category.name ?? "Category")
        .fullScreenCover(
            isPresented: Binding(
                get: { selectedIndex != nil },
                set: { if !$0 { selectedIndex = nil } }
            )
        ) {
            if let i = selectedIndex {
                ScreenshotPreviewView(
                    screenshots: shots,
                    selectedIndex: Binding(
                        get: { i },
                        set: { selectedIndex = $0 }
                    )
                )
            }
        }
    }
}

